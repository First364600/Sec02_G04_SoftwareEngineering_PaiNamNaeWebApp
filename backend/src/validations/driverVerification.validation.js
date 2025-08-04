const { z } = require('zod');
const { VerificationStatus } = require('@prisma/client');

const createDriverVerificationSchema = z.object({
  licenseNumber: z.string().min(1, 'License number is required'),
  firstNameOnLicense: z.string().min(1, 'First name on license is required'),
  lastNameOnLicense: z.string().min(1, 'Last name on license is required'),
  licenseIssueDate: z.string().refine(val => !isNaN(Date.parse(val)), {
    message: 'Invalid date format for licenseIssueDate',
  }),
  licenseExpiryDate: z.string().refine(val => !isNaN(Date.parse(val)), {
    message: 'Invalid date format for licenseExpiryDate',
  }),
});

const idParamSchema = z.object({
  id: z.string().cuid({ message: 'Invalid DriverVerification ID format' }),
});

const updateDriverVerificationSchema = createDriverVerificationSchema.partial();

const updateVerificationStatusSchema = z.object({
  status: z.nativeEnum(VerificationStatus, {
    required_error: 'Status is required',
    invalid_type_error: 'Invalid status value',
  }),
});

module.exports = {
  idParamSchema,
  createDriverVerificationSchema,
  updateDriverVerificationSchema,
  updateVerificationStatusSchema,
};
