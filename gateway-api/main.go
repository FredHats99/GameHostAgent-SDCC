package main

import (
	"fmt"
	"log"

	"github.com/gofiber/fiber/v2"
)

func main() {
	app := fiber.New()

	// Endpoint di test
	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Gateway API OK")
	})

	// Endpoint session (dummy)
	app.Post("/session", func(c *fiber.Ctx) error {
		type SessionRequest struct {
			User string `json:"user"`
		}
		req := new(SessionRequest)
		if err := c.BodyParser(req); err != nil {
			return c.Status(400).SendString("Bad request")
		}

		// Risposta dummy: in futuro qui ci sarà SDP + ICE
		resp := fmt.Sprintf("Sessione creata per %s", req.User)
		return c.JSON(fiber.Map{"message": resp})
	})

	log.Println("Gateway API in ascolto su :8080")
	log.Fatal(app.Listen(":8080"))
}
