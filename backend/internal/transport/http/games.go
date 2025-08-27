package http

import (
	"backend/internal/config"
	"backend/internal/middleware"
	"context"

	"github.com/gofiber/fiber/v2"
	"github.com/jackc/pgx/v5/pgxpool"
)

func RegisterGames(api fiber.Router, pool *pgxpool.Pool, cfg *config.Config) {
	grp := api.Group("/games")
	grp.Use(middleware.RequireAdmin(middleware.JWTConfig{Secret: cfg.JWTSecret}))

	grp.Get("/:id", func(c *fiber.Ctx) error {
		id := c.Params("id")
		var json string
		err := pool.QueryRow(context.Background(), `select jsonb_build_object(
            'id', g.id,
            'name', g.name,
            'rulesHtml', g.rules_html,
            'bases', g.bases,
            'enigmas', g.enigmas
        ) from games g where g.id=$1`, id).Scan(&json)
		if err != nil {
			return fiber.ErrNotFound
		}
		return c.Type("json").SendString(json)
	})

	grp.Post("/", func(c *fiber.Ctx) error {
		var body map[string]any
		if err := c.BodyParser(&body); err != nil {
			return fiber.ErrBadRequest
		}
		err := pool.QueryRow(context.Background(),
			`insert into games (name, rules_html, bases, enigmas) values ($1,$2,$3,$4) returning id`,
			body["name"], body["rulesHtml"], body["bases"], body["enigmas"],
		).Scan(new(string))
		if err != nil {
			return fiber.ErrInternalServerError
		}
		return c.SendStatus(fiber.StatusCreated)
	})
}
