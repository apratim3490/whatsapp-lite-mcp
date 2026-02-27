package api

import (
	"fmt"
	"net/http"

	"whatsapp-bridge/internal/database"
	"whatsapp-bridge/internal/webhook"
	"whatsapp-bridge/internal/whatsapp"
)

// Server is the HTTP REST API server for the WhatsApp bridge.
// It exposes endpoints for sending messages, managing webhooks,
// group operations, and other WhatsApp features.
type Server struct {
	client         *whatsapp.Client
	messageStore   *database.MessageStore
	webhookManager *webhook.Manager
	port           int
}

// NewServer creates a new API server with the given dependencies.
//
// Parameters:
//   - client: WhatsApp client for sending messages and interacting with WhatsApp
//   - messageStore: Database for message history and webhook configurations
//   - webhookManager: Manager for webhook trigger matching and delivery
//   - port: TCP port to listen on (e.g., 8080)
func NewServer(client *whatsapp.Client, messageStore *database.MessageStore, webhookManager *webhook.Manager, port int) *Server {
	return &Server{
		client:         client,
		messageStore:   messageStore,
		webhookManager: webhookManager,
		port:           port,
	}
}

// Start launches the HTTP server in a background goroutine.
// The server listens on the configured port and serves the REST API.
// This method returns immediately; use a blocking mechanism in main().
func (s *Server) Start() {
	// Register handlers
	s.registerHandlers()

	// Start the server
	serverAddr := fmt.Sprintf(":%d", s.port)
	fmt.Printf("Starting REST API server on %s...\n", serverAddr)

	// Run server in a goroutine so it doesn't block
	go func() {
		if err := http.ListenAndServe(serverAddr, nil); err != nil {
			fmt.Printf("REST API server error: %v\n", err)
		}
	}()
}

// registerHandlers sets up all API routes with security middleware.
// All endpoints are protected by SecureMiddleware which enforces:
// API key authentication, rate limiting, CORS, and security headers.
func (s *Server) registerHandlers() {
	// Health check - no auth (for Docker healthcheck / load balancers)
	http.HandleFunc("/api/health", CorsMiddleware(s.handleHealth))

	// Message sending endpoint
	http.HandleFunc("/api/send", SecureMiddleware(s.handleSendMessage))

	// All other routes disabled — send-only mode.
}
