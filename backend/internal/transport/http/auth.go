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
	api.Post("/auth/login", func(c *fiber.Ctx) error {
		var req loginRequest
		if err := c.BodyParser(&req); err != nil {
			return fiber.ErrBadRequest
		}
		// Placeholder: accept any credentials for now
		token, err := middleware.GenerateToken(cfg.JWTSecret, "admin-1")
		if err != nil {
			return fiber.ErrInternalServerError
		}
		return c.JSON(fiber.Map{"token": token, "user": fiber.Map{"id": "admin-1", "email": req.Email, "role": "admin"}})
	})
}
