import { assertEquals } from "https://deno.land/std@0.221.0/assert/mod.ts";


// Import the handler function
import { handler } from "../../functions/reverseString/index.ts";

const mockRequest = (body: unknown): Request =>
  new Request("http://localhost", {
    method: "POST",
    body: JSON.stringify(body),
    headers: { "Content-Type": "application/json" },
  });

Deno.test("Reverse String Function", async () => {
  // Mock request
  const request =  mockRequest({ text: "hello" });

  // Call the handler function
  const response = await handler(request);
  const json = await response.json();

  // Check if the response is correct
  assertEquals(json.reversedString, "olleh");
});