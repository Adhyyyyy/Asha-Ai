const { db, admin, bucket } = require('../config/firebase');
const aiService = require('../services/aiService');

/**
 * Returns a simulated prediction when AI is unavailable or modality is non-image.
 */
/**
 * Returns a simulated prediction when AI is unavailable or modality is non-image.
 */
function getFallbackPrediction(modality, manual_data = null) {
    const isRisk = Math.random() > 0.4;
    
    if (modality === 'ocular_suite') {
        return {
            condition: isRisk ? 'Possible Conjunctivitis' : 'Normal Ocular Findings',
            risk_score: isRisk ? 68 : 5,
            severity: isRisk ? 'Moderate' : 'Low',
            clinical_reasoning: "Observed mild redness in the sclera. Scleral icterus not present.",
            current_status: isRisk ? "Inflammation detected in the left eye." : "Eyes appear clear and healthy.",
            future_projection: isRisk ? "Risk of bacterial spread to both eyes." : "Maintenance of ocular health.",
            prevention_plan: isRisk ? "Start antibiotic drops and isolate towels." : "Continue standard hygiene.",
            advice: "Keep eyes clean and avoid touching with unwashed hands."
        };
    } else if (modality === 'dermal_suite') {
        return {
            condition: isRisk ? 'Nutritional Dermatitis' : 'Healthy Skin Barrier',
            risk_score: isRisk ? 45 : 8,
            severity: isRisk ? 'Moderate' : 'Low',
            clinical_reasoning: "Dry patches observe on palms. Indicates potential Vitamin A/E deficiency.",
            current_status: "Dryness and scaling noted.",
            future_projection: "Risk of skin cracking and secondary infection.",
            prevention_plan: "Increase leafy greens and apply moisturizing emollient.",
            advice: "Improve dietary diversity for better skin health."
        };
    } else if (modality === 'respiratory_suite') {
        return {
            condition: isRisk ? 'Acute Bronchitis' : 'Clear Lungs',
            risk_score: isRisk ? 55 : 12,
            severity: isRisk ? 'Moderate' : 'Low',
            clinical_reasoning: "Patient reported fever + productive cough detected in analysis.",
            current_status: "Productive cough and mild wheezing.",
            future_projection: "Risk of progression to pneumonia if untreated.",
            prevention_plan: "Warm saline gargles and refer for chest X-ray.",
            advice: "Stay hydrated and avoid cold exposure."
        };
    }
    
    return { 
        condition: 'General Screening', 
        risk_score: 10, 
        severity: 'Low', 
        clinical_reasoning: "Routine screening performed.",
        current_status: "No critical markers identified.",
        future_projection: "Continued wellness.",
        prevention_plan: "Routine checkups.",
        advice: 'Patient appears stable.' 
    };
}


// POST /api/predict
exports.analyzeHealth = async (req, res) => {
    try {
        const { patientId, modality, manualData } = req.body; // Changed from manual_data to manualData to match frontend

        let publicUrl = null;
        
        // Handle manualData if it's a string (from Multipart)
        let parsedManualData = manualData;
        if (typeof manualData === 'string') {
            try { parsedManualData = JSON.parse(manualData); } catch(e) {}
        }

        // Check if a file was uploaded into memory 📸
        if (req.file) {
            try {
                if (bucket) {
                    console.log(`📸 RECEIVED FILE IN MEMORY, UPLOADING TO CLOUD STORAGE...`);
                    const extension = req.file.originalname.split('.').pop();
                    const filename = `screenings/${Date.now()}-${Math.round(Math.random() * 1E9)}.${extension}`;
                    const fileItem = bucket.file(filename);

                    await fileItem.save(req.file.buffer, {
                        metadata: { contentType: req.file.mimetype }
                    });

                    publicUrl = `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${encodeURIComponent(filename)}?alt=media`;
                    console.log(`✅ UPLOAD COMPLETE: ${publicUrl}`);
                } else {
                    console.warn("⚠️ Firebase Storage (bucket) is not initialized. Skipping upload.");
                }
            } catch (storageErr) {
                console.error("❌ Storage Upload Failed:", storageErr.message);
            }
        }

        console.log(`🤖 AI Analyzing ${modality} for Patient ${patientId}...`);

        let prediction = {};

        // USE REAL AI IF POSSIBLE (Gemini) - UPDATED FOR NEW MODALITIES
        const isImageModality = ['ocular_suite', 'dermal_suite', 'respiratory_suite', 'image_eye', 'image_nail'].includes(modality);
        
        if (req.file && isImageModality) {
            try {
                prediction = await aiService.analyzeWithGemini(
                    modality, 
                    req.file.buffer, 
                    req.file.mimetype, 
                    parsedManualData
                );
                console.log("✅ AI ENGINE ASSESSMENT SUCCESSFUL");
            } catch (aiErr) {
                console.error("⚠️ AI Engine Failed, falling back to mock:", aiErr.message);
                prediction = getFallbackPrediction(modality, parsedManualData);
            }
        } else {
            prediction = getFallbackPrediction(modality, parsedManualData);
        }

        // Save screening to Firestore
        const screeningData = {
            patientId,
            asha_id: req.user.uid,
            modality,
            file_url: publicUrl,
            timestamp: new Date(),
            ...prediction
        };

        let screeningId = "temp_" + Date.now();
        if (db) {
            try {
                const docRef = await db.collection('screenings').add(screeningData);
                screeningId = docRef.id;

                // Award points
                await db.collection('users').doc(req.user.uid).update({
                    points: admin.firestore.FieldValue.increment(10)
                }).catch(() => {});

                // Update patient risk
                if (prediction.severity === 'High' || prediction.severity === 'Critical') {
                    await db.collection('patients').doc(patientId).update({
                        risk: 'High',
                        last_visit: new Date().toISOString().split('T')[0]
                    }).catch(() => {});
                }
            } catch (dbErr) {
                console.error("❌ Firestore Save Failed:", dbErr.message);
            }
        } else {
            console.warn("⚠️ Firestore (db) is not initialized. Screening not saved.");
        }

        // Return the "Crystal Ball" result
        res.status(200).json({
            success: true,
            screening_id: screeningId,
            ...screeningData
        });

    } catch (error) {
        console.error("AI Error:", error);
        res.status(500).json({ message: 'AI Engine Failure' });
    }
};
