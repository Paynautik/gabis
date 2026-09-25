import { logger } from 'firebase-functions';
import { genkit } from 'genkit';
import { googleAI, gemini15Flash } from '@genkit-ai/googleai';

// Initialize Genkit for Gemini (Fallback)
const ai = genkit({
  plugins: [googleAI()], 
  model: gemini15Flash,
});

/**
 * AI Connector: Dual-Model Setup
 * Tries Meta's Llama 3 (via Groq) first, falls back to Google's Gemini if it fails.
 */
export async function generateMuseResponse(prompt: string, contextData: any = {}): Promise<string> {
  logger.info('Muse AI processing prompt:', { prompt, contextData });
  
  const channelContext = contextData.channel === 'whatsapp' 
    ? 'You are Gabis Assistant, responding to a user via WhatsApp. Be concise, friendly, and helpful with their payments and savings.'
    : 'You are Gabis Copilot, an in-app AI financial advisor. Answer the user about their 5-currency wallet, Ajo savings circles, or Escrow disputes.';

  const systemPrompt = `${channelContext} Keep your answer brief and directly address their query.`;

  // 1. Try Meta Llama 3 (via Groq) as PRIMARY
  try {
    const groqApiKey = process.env.GROQ_API_KEY;
    
    if (groqApiKey) {
      const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${groqApiKey}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          model: 'llama3-8b-8192', // Meta's Llama 3 8B model
          messages: [
            { role: 'system', content: systemPrompt },
            { role: 'user', content: prompt }
          ],
          temperature: 0.7,
        })
      });

      if (response.ok) {
        const data = await response.json() as any;
        logger.info('Successfully generated response using PRIMARY (Meta Llama 3)');
        return data.choices[0].message.content;
      } else {
        logger.warn(`Groq API returned ${response.status}. Falling back...`);
      }
    } else {
      logger.warn('GROQ_API_KEY is missing. Falling back...');
    }
  } catch (error) {
    logger.warn("Meta Llama 3 (Groq) failed. Falling back to Gemini...", error);
  }

  // 2. Fallback to Gemini (via Genkit)
  try {
    const { text } = await ai.generate({
      system: systemPrompt,
      prompt: prompt,
    });
    
    if (text) {
      logger.info('Successfully generated response using FALLBACK (Gemini)');
      return text;
    }
    
    return "I'm sorry, I couldn't generate a response at this time.";
  } catch (fallbackError) {
    logger.error("Gemini fallback also failed:", fallbackError);
    return "Sorry, both of my AI engines are currently experiencing connection issues. Please try again later.";
  }
}
