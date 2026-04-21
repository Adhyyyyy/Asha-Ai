const { GoogleGenerativeAI } = require("@google/generative-ai");

/**
 * Analyzes an image (and optional data) using Gemini models.
 */
exports.analyzeWithGemini = async (modality, mediaDataBuffer, mimeType, manualData = null) => {
    try {
        // Dynamic MIME type handling for Images & Audio
        let safeMimeType = mimeType;
        if (!mimeType || mimeType === 'application/octet-stream') {
            if (modality === 'respiratory_suite') {
                safeMimeType = 'audio/m4a';
            } else {
                safeMimeType = 'image/jpeg';
            }
        }
        console.log(`� Processing ${modality} media with MIME: ${safeMimeType}`);

        // Initialize inside the function to ensure process.env.GEMINI_API_KEY is loaded
        const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

        // Updated model priority list based on user's specific authorized models
        const modelNames = ["gemini-flash-latest", "gemini-2.0-flash", "gemini-1.5-flash"];
        let model;
        let lastError;

        for (const name of modelNames) {
            try {
                console.log(`🤖 Testing Gemini model: ${name}...`);
                model = genAI.getGenerativeModel({ model: name });
                
                // Build the prompt based on modality Diagnostic Suites
                let prompt = "";
                if (modality === 'ocular_suite') {
                    prompt = "PERFORM COMPREHENSIVE OCULAR EXAM: Analyze eye image for 1. Anemia (Conjuctival Paleness), 2. Jaundice (Scleral Icterus), 3. Infections (Redness/Discharge).";
                } else if (modality === 'dermal_suite') {
                    prompt = "PERFORM DERMATOLOGICAL SCAN: Analyze skin for rashes, nutritional indicators, or wound healing signs.";
                } else if (modality === 'respiratory_suite') {
                    prompt = "PERFORM RESPIRATORY ASSESSMENT: Analyze audio/context for infection markers, lung sound clarity, and breathing effort.";
                } else {
                    prompt = "PERFORM GENERAL CLINICAL SCREENING: Analyze visual and contextual health data.";
                }

                prompt += `
                ROLE: Senior Medical Consultant & Diagnostic Expert.
                PHILOSOPHY: Care Before Cure. Precision early detection is life-saving.
                THINKING PROCESS: Use Chain-of-Thought. Document clinical observations, then logical deductions, then the final assessment.
                
                Additional Context: ${JSON.stringify(manualData || {})}
                
                Return the result STRICTLY as a JSON object with these fields:
                {
                  "condition": "Likely Condition Name",
                  "risk_score": 0-100 (integer),
                  "severity": "Low" | "Moderate" | "High" | "Critical",
                  "clinical_reasoning": "Step-by-step clinical logic (e.g. 'Observed X -> Indicates Y -> Conclusion Z')",
                  "current_status": "Brief summary of clinical findings right now",
                  "future_projection": "What this will turn into if left untreated",
                  "prevention_plan": "Immediate life-saving actions to take NOW",
                  "advice": "Empathetic medical advice for the ASHA worker"
                }
                `;

                // Prepare image for Gemini
                const imageParts = [
                    {
                        inlineData: {
                            data: mediaDataBuffer.toString("base64"),
                            mimeType: safeMimeType
                        },
                    },
                ];

                const result = await model.generateContent([prompt, ...imageParts]);
                const response = await result.response;
                const text = response.text();
                
                // If we got here, it worked!
                console.log(`✅ Model ${name} worked!`);
                const cleanJson = text.replace(/```json|```/g, "").trim();
                return JSON.parse(cleanJson);

            } catch (err) {
                console.warn(`⚠️ Model ${name} failed: ${err.message}`);
                lastError = err;
                continue; // Try next model
            }
        }
        
        throw lastError; // If all failed, throw the last error

    } catch (error) {
        console.error("Gemini AI Service Error:", error);
        throw new Error("Failed to process health data with AI");
    }
};
