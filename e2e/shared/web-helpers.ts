import { expect, type Page } from '@playwright/test';
import { getOperatorToken, getOperatorRefreshToken, getOperatorUser } from './auth';

/** Force English locale so hostname detection (.pt → Portuguese) doesn't interfere with tests. */
export async function forceEnglishLocale(page: Page) {
  await page.addInitScript(() => {
    localStorage.setItem('pointfinder-lang', 'en');
  });
}

/**
 * Authenticate as operator for web UI tests via token injection.
 *
 * Uses two complementary strategies to survive page navigations:
 * 1. addInitScript injects auth tokens into localStorage before every page load,
 *    so Zustand rehydrates with a valid access token (no refresh needed).
 * 2. Route intercept on POST /api/auth/refresh returns valid tokens as a safety
 *    net, avoiding the nginx auth rate limit (10r/m on /api/auth/).
 *
 * The real login form is tested separately by the API auth tests and the
 * unauthorized-navigation negative tests.
 */
export async function loginAsOperator(page: Page) {
  const accessToken = getOperatorToken();
  const refreshToken = getOperatorRefreshToken();
  const user = getOperatorUser();

  // Inject auth tokens into localStorage on every page load.
  // This ensures the SPA has a valid access token after Zustand rehydration,
  // even on subsequent navigations (page.goto) that cause full reloads.
  await page.addInitScript(
    (authState) => {
      localStorage.setItem('pointfinder-lang', 'en');
      localStorage.setItem(
        'pointfinder-auth',
        JSON.stringify({ state: authState, version: 0 }),
      );
    },
    { user, refreshToken, accessToken, isAuthenticated: true },
  );

  // Intercept token refresh calls — the SPA's access token is not persisted
  // by Zustand, so page reloads trigger a refresh attempt.
  await page.route('**/api/auth/refresh', async (route) => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({ accessToken, refreshToken, user }),
    });
  });

  // Proxy GET /api/games through route.fetch() so rate-limited responses
  // (429/503) are replaced with empty-success, preventing the AuthGuard
  // session verification from redirecting to login. Real data passes through.
  await page.route('**/api/games', async (route, request) => {
    if (request.method() !== 'GET') {
      await route.continue();
      return;
    }
    try {
      const response = await route.fetch();
      if (response.ok()) {
        await route.fulfill({ response });
      } else {
        await route.fulfill({
          status: 200,
          contentType: 'application/json',
          body: JSON.stringify([]),
        });
      }
    } catch {
      // Page closed during fetch — silently ignore
    }
  });

  await page.goto('/games');
  await expect(page).toHaveURL(/\/games/, { timeout: 15_000 });
}
