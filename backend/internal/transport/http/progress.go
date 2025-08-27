package http

import (
	"backend/internal/config"
	"backend/internal/middleware"
	"context"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/jackc/pgx/v5/pgxpool"
)

func RegisterProgress(api fiber.Router, pool *pgxpool.Pool, cfg *config.Config) {
	grp := api.Group("/progress")
	grp.Use(middleware.RequireAdmin(middleware.JWTConfig{Secret: cfg.JWTSecret}))

	grp.Get("/teams/:id", func(c *fiber.Ctx) error {
		id := c.Params("id")
		rows, err := pool.Query(context.Background(), `select base_id, arrived_at, solved_at, completed_at, score from progress where team_id=$1`, id)
		if err != nil {
			return fiber.ErrInternalServerError
		}
		defer rows.Close()
		list := make([]fiber.Map, 0)
		for rows.Next() {
			var baseId string
			var arrived, solved, completed *time.Time
			var score int
			if err := rows.Scan(&baseId, &arrived, &solved, &completed, &score); err != nil {
				return fiber.ErrInternalServerError
			}
			list = append(list, fiber.Map{"baseId": baseId, "arrivedAt": arrived, "solvedAt": solved, "completedAt": completed, "score": score})
		}
		return c.JSON(list)
	})
}
