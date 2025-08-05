const { z } = require("zod");
const { RouteStatus } = require("@prisma/client");

const createRouteSchema = z.object({
  // driverId: z.string().cuid({ message: "driverId must be a CUID" }),
  vehicleId: z.string().cuid({ message: "vehicleId must be a CUID" }),
  startLocation: z.any(),
  endLocation: z.any(),
  departureTime: z.string().refine((val) => !isNaN(Date.parse(val)), {
    message: "Invalid datetime format",
  }),
  availableSeats: z.number().int().nonnegative(),
  pricePerSeat: z.number().nonnegative(),
  conditions: z.string().optional(),
  status: z.nativeEnum(RouteStatus).optional(),
  routeSummary: z.string().optional(),
  distance: z.string().optional(),
  duration: z.string().optional(),
  waypoints: z.any().optional(),
  landmarks: z.any().optional(),
  steps: z.any().optional(),
});

const idParamSchema = z.object({
  id: z.string().cuid({ message: "Invalid route ID format" }),
});

const updateRouteSchema = createRouteSchema.partial();

module.exports = {
  idParamSchema,
  createRouteSchema,
  updateRouteSchema,
};
