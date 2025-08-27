package http

import (
	"backend/internal/config"
	"backend/internal/middleware"

	"github.com/gofiber/fiber/v2"
)

type loginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

func RegisterAuth(api fiber.Router, cfg *config.Config) {
	// Admin login endpoint (matches iOS client expectation)
	api.Post("/auth/admin/login", func(c *fiber.Ctx) error {
		var req struct {
			Username string `json:"username"`
			Password string `json:"password"`
		}
		if err := c.BodyParser(&req); err != nil {
			return fiber.ErrBadRequest
		}
		
		// TODO: Replace with proper credential validation before production
		// For now, require specific admin credentials
		if req.Username != "admin" || req.Password != "secure_admin_password_2024!" {
			return fiber.ErrUnauthorized
		}
		
		token, err := middleware.GenerateToken(cfg.JWTSecret, "admin-1")
		if err != nil {
			return fiber.ErrInternalServerError
		}
		return c.JSON(fiber.Map{"token": token})
	})

	// Keep legacy endpoint for web admin compatibility
	api.Post("/auth/login", func(c *fiber.Ctx) error {
		var req loginRequest
		if err := c.BodyParser(&req); err != nil {
			return fiber.ErrBadRequest
		}
		
		// TODO: Replace with proper credential validation before production
		if req.Email != "admin@example.com" || req.Password != "secure_admin_password_2024!" {
			return fiber.ErrUnauthorized
		}
		
		token, err := middleware.GenerateToken(cfg.JWTSecret, "admin-1")
		if err != nil {
			return fiber.ErrInternalServerError
		}
		return c.JSON(fiber.Map{"token": token, "user": fiber.Map{"id": "admin-1", "email": req.Email, "role": "admin"}})
	})

	// Team join endpoint for mobile clients
	api.Post("/auth/team/join", func(c *fiber.Ctx) error {
		var req struct {
			Code     string `json:"code"`
			DeviceId string `json:"deviceId"`
		}
		if err := c.BodyParser(&req); err != nil {
			return fiber.ErrBadRequest
		}
		
		// TODO: Implement proper team join code validation
		// For now, accept any 6-digit code and return mock team data
		if len(req.Code) != 6 {
			return c.Status(400).JSON(fiber.Map{"error": "Invalid join code"})
		}
		
		// Generate team token
		token, err := middleware.GenerateToken(cfg.JWTSecret, "team-"+req.Code)
		if err != nil {
			return fiber.ErrInternalServerError
		}
		
		// Mock team data - TODO: fetch from database
		team := fiber.Map{
			"id": "team-" + req.Code,
			"name": "Team " + req.Code,
			"members": []string{req.DeviceId},
			"leaderDeviceId": req.DeviceId,
		}
		
		return c.JSON(fiber.Map{"token": token, "team": team})
	})
}
