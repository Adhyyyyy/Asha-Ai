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
                console.log(`🤖 Testing AI Engine model: ${name}...`);
                model = genAI.getGenerativeModel({ model: name });
                
                // Build the prompt based on modality Diagnostic Suites
                let prompt = "";
                if (modality === 'ocular_suite') {
                    prompt = "PERFORM COMPREHENSIVE OCULAR EXAM: Analyze eye image for 1. Anemia (Conjunctival Pallor), 2. Jaundice (Scleral Icterus), 3. Infections (Redness/Discharge).";
                } else if (modality === 'dermal_suite') {
                    prompt = "PERFORM DERMATOLOGICAL SCAN: Analyze skin for rashes, nutritional indicators, infections, or wound healing signs.";
                } else if (modality === 'respiratory_suite') {
                    prompt = "PERFORM RESPIRATORY ASSESSMENT: Analyze audio/context for infection markers, lung sound clarity, and breathing effort.";
                } else {
                    prompt = "PERFORM GENERAL CLINICAL SCREENING: Analyze visual and contextual health data.";
                }

                prompt += `
                ROLE: You are an expert medical AI assisting rural ASHA (Accredited Social Health Activist) workers in India.
                ENVIRONMENT CONTEXT: You must recommend treatments and next steps that are realistic for rural Indian healthcare (e.g., refer to Primary Health Centre (PHC), Community Health Centre (CHC), or District Hospital). Do not suggest expensive or inaccessible tests unless absolutely critical for survival.
                
                PATIENT CONTEXT: ${JSON.stringify(manualData || {})}
                
                INSTRUCTIONS:
                1. First, observe the visual or audio evidence carefully.
                2. Second, correlate your findings with the patient context provided.
                3. Third, determine the most likely condition and risk score based on ASHA guidelines.
                4. Finally, output the results STRICTLY as a JSON object. Do NOT include markdown formatting like \`\`\`json.
                
                EXPECTED JSON SCHEMA:
                {
                  "condition": "Likely Condition Name",
                  "risk_score": 0-100,
                  "severity": "Low" | "Moderate" | "High" | "Critical",
                  "clinical_reasoning": "Detailed chain of thought. E.g., '1. Observed pale conjunctiva. 2. Patient reports fatigue. 3. Indicates anemia...'",
                  "current_status": "Brief summary of clinical findings",
                  "future_projection": "What this will turn into if left untreated",
                  "prevention_plan": "Immediate, realistic actions for the ASHA worker (e.g., 'Provide Iron-Folic Acid tablets', 'Refer to PHC')",
                  "advice": "Simple, empathetic advice the ASHA worker can tell the patient"
                }
                
                EXAMPLE OF A PERFECT RESPONSE:
                {
                  "condition": "Severe Anemia",
                  "risk_score": 85,
                  "severity": "High",
                  "clinical_reasoning": "1. Visual assessment shows extreme conjunctival pallor. 2. Patient age puts her at high risk. 3. Lack of other symptoms rules out jaundice but confirms severe iron deficiency.",
                  "current_status": "Patient is exhibiting signs of severe blood iron depletion.",
                  "future_projection": "If untreated, can lead to severe weakness, heart failure, or complications in pregnancy.",
                  "prevention_plan": "Immediately provide Iron-Folic Acid (IFA) supplements. Refer patient to the nearest PHC today for a hemoglobin blood test.",
                  "advice": "Please tell the patient she needs to eat more iron-rich foods like jaggery and spinach, and take the red tablets daily without fail."
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
        console.error("AI Engine Service Error:", error);
        throw new Error("Failed to process health data with AI");
    }
};
