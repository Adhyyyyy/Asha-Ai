/* src/controllers/aiController.js */

// POST /api/predict
exports.analyzeHealth = async (req, res) => {
    try {
        const { patientId, modality, file_path, manual_data } = req.body;

        // SIMULATED AI ENGINE 🧠
        // In reality, this would call a Python Model or TensorFlow Lite

        console.log(`🤖 AI Analyzing ${modality} for Patient ${patientId}...`);

        let prediction = {};

        // 1. ANEMIA DETECTION (Eye/Nail Image)
        if (modality === 'image_eye' || modality === 'image_nail') {
            // Simulated Logic: Random Check or based on filename for testing
            const isRisk = Math.random() > 0.5;

            prediction = {
                condition: 'Anemia',
                risk_score: isRisk ? 85 : 12, // % Probability
                severity: isRisk ? 'High' : 'Low',
                confidence: 94.5,
                early_signs: isRisk
                    ? ['Pallor in Conjunctiva', 'Blue-ish Nail Beds']
                    : ['Healthy vascularization observed'],
                advice: isRisk
                    ? 'Start Iron Folic Acid supplements immediately.'
                    : 'Continue standard nutrition.'
            };
        }

        // 2. RESPIRATORY ANALYSIS (Cough Audio)
        else if (modality === 'audio_cough') {
            const isRisk = Math.random() > 0.7;

            prediction = {
                condition: 'Respiratory Infection',
                risk_score: isRisk ? 78 : 5,
                severity: isRisk ? 'Moderate' : 'None',
                confidence: 88.2,
                early_signs: isRisk
                    ? ['Wheezing detected (1200Hz)', 'Shortness of breath pattern']
                    : ['Clear breathing sounds'],
                advice: isRisk
                    ? 'Refer to PHC for chest X-ray.'
                    : 'Monitor for fever.'
            };
        }

        // 3. MATERNAL RISK (BP + Swelling)
        else if (modality === 'manual_maternal') {
            const { sys, dia } = manual_data || {};
            const isHighBP = (sys > 140 || dia > 90);

            prediction = {
                condition: 'Preeclampsia',
                risk_score: isHighBP ? 92 : 15,
                severity: isHighBP ? 'Critical' : 'Safe',
                confidence: 99.9, // Measurements are precise
                early_signs: isHighBP
                    ? ['Hypertension Stage 2', 'Potential Edema Link']
                    : ['Normal Blood Pressure'],
                advice: isHighBP
                    ? 'URGENT: Transport to Hospital. Administer Magnesium Sulfate if trained.'
                    : 'Routine antenatal care.'
            };
        }

        // Return the "Crystal Ball" result
        res.status(200).json({
            success: true,
            timestamp: new Date(),
            ...prediction
        });

    } catch (error) {
        console.error("AI Error:", error);
        res.status(500).json({ message: 'AI Engine Failure' });
    }
};
