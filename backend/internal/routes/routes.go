package routes

import (
	"backend/internal/config"
	"backend/internal/transport/http"

	"github.com/gofiber/fiber/v2"
	"github.com/jackc/pgx/v5/pgxpool"
)

func Register(app *fiber.App, cfg *config.Config, pool *pgxpool.Pool) {
	api := app.Group("/api")

	http.RegisterAuth(api, cfg)
	http.RegisterGames(api, pool, cfg)
	http.RegisterTeams(api, pool, cfg)
	http.RegisterProgress(api, pool, cfg)
	http.RegisterEvents(api, pool, cfg)
}
