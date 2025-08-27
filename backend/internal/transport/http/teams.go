package http

import (
	"backend/internal/config"
	"backend/internal/middleware"
	"context"

	"github.com/gofiber/fiber/v2"
	"github.com/jackc/pgx/v5/pgxpool"
)

func RegisterTeams(api fiber.Router, pool *pgxpool.Pool, cfg *config.Config) {
	grp := api.Group("/teams")
	grp.Use(middleware.RequireAdmin(middleware.JWTConfig{Secret: cfg.JWTSecret}))

	grp.Get("/", func(c *fiber.Ctx) error {
		rows, err := pool.Query(context.Background(), `select id, name from teams order by name`)
		if err != nil {
			return fiber.ErrInternalServerError
		}
		defer rows.Close()
		list := make([]fiber.Map, 0)
		for rows.Next() {
			var id, name string
			if err := rows.Scan(&id, &name); err != nil {
				return fiber.ErrInternalServerError
			}
			list = append(list, fiber.Map{"id": id, "name": name})
		}
		return c.JSON(list)
	})

	grp.Post("/", func(c *fiber.Ctx) error {
		var body struct {
			Name string `json:"name"`
		}
		if err := c.BodyParser(&body); err != nil {
			return fiber.ErrBadRequest
		}
		if body.Name == "" {
			return fiber.ErrBadRequest
		}
		if _, err := pool.Exec(context.Background(), `insert into teams (name) values ($1)`, body.Name); err != nil {
			return fiber.ErrInternalServerError
		}
		return c.SendStatus(fiber.StatusCreated)
	})
}
