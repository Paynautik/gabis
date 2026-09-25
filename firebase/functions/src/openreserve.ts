import { ORPay } from '@openreserve/orpay';

export const orpay = new ORPay({
  apiKey: process.env.ORPAY_API_KEY || 'test_api_key',
  baseUrl: process.env.ORPAY_URL || 'http://localhost:8080'
});
