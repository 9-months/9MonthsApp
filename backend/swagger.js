const swaggerJsDoc = require("swagger-jsdoc");
const swaggerUi = require("swagger-ui-express");

const swaggerOptions = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "9Months API - Pregnancy Support & Wellness",
      version: "1.0.0",
      description: "API documentation for the 9Months app, providing pregnancy tracking, health monitoring, appointment reminders, partner guidance, and emergency support for expectant mothers in Sri Lanka.",
    },
    servers: [
      {
        url: "http://localhost:3000",
        description: "Development Server",
      },
    ],
  },
  apis: ["./routes/*.js"], // Path to your API routes
};

const swaggerSpec = swaggerJsDoc(swaggerOptions);

module.exports = (app) => {
  app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));
};
