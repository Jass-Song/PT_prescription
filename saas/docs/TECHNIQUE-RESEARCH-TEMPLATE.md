# [Technique Name] Research Sheet

<!-- owner: technique-researcher -->

## 1. Basic Information

| Field | Content |
|------|------|
| Korean name | |
| English name | |
| Abbreviation | |
| Category | category_a_joint_mobilization / category_b_mulligan / category_c_manipulation / category_d_neural / category_e_soft_tissue |
| Body region | cervical / thoracic / lumbar / shoulder / elbow / wrist / hip / knee / ankle / foot |
| Specific segment | C3-C4 / L4-L5 etc. (if applicable) |
| Maitland Grade | I / II / III / IV (mark applicable) |

---

## 2. Algorithm Tags (required — core of AI recommendation)

> Select applicable items from the checkboxes below. Multiple selections allowed. Do not check broadly without evidence.

### 2-1. Treatment purpose tags (purpose_tags) — check applicable items

- [ ] pain_relief — pain reduction
- [ ] rom_improvement — joint range of motion improvement
- [ ] neurodynamics — neural symptoms (neural mobility)
- [ ] stabilization — stabilization
- [ ] proprioception — proprioceptive retraining

### 2-2. Target patient tags (target_tags) — check applicable items

- [ ] acute — acute (onset 0-2 weeks)
- [ ] subacute — subacute (2-12 weeks)
- [ ] chronic — chronic (12+ weeks)
- [ ] post_surgical — post-surgical
- [ ] hypermobile — hypermobile
- [ ] hypomobile — hypomobile (joint stiffness)

### 2-3. Symptom tags (symptom_tags) — check applicable items

- [ ] movement_pain — pain with movement
- [ ] rest_pain — pain at rest
- [ ] radicular_pain — radicular / radiating pain
- [ ] radiculopathy — radiculopathy (confirmed nerve compression)
- [ ] Other (enter directly):

### 2-4. Contraindication tags (contraindication_tags) — check applicable items

**Absolute contraindications:**
- [ ] vbi_risk — vertebrobasilar insufficiency risk (must verify for cervical techniques)
- [ ] fracture — fracture (including suspected)
- [ ] instability — instability (including ligament rupture, spinal instability)
- [ ] malignancy — tumor / malignancy
- [ ] neurological_deficit — neurological deficit (muscle weakness, reflex loss, bladder/bowel dysfunction)

**Relative contraindications:**
- [ ] osteoporosis — osteoporosis
- [ ] inflammation_acute — acute inflammation (infection, rheumatoid flare)
- [ ] Other absolute contraindication (enter directly):
- [ ] Other relative contraindication (enter directly):

---

## 3. Initial Recommendation Weight Setting

| Field | Value | Rationale |
|------|-----|------|
| recommendation_weight | 0.00 ~ 1.00 | (e.g., 0.85 — 2 RCTs, high clinical utility) |
| Evidence level (evidence_level) | level_1a / 1b / 2a / 2b / 3 / 4 / 5 / insufficient | |

**Evidence level criteria:**

| Level | Definition |
|------|------|
| level_1a | Systematic review of homogeneous RCTs |
| level_1b | Individual RCT (narrow confidence interval) |
| level_2a | Systematic review of homogeneous cohort studies |
| level_2b | Individual cohort study or low-quality RCT |
| level_3 | Case-control study or low-quality cohort study |
| level_4 | Case report or low-quality case-control study |
| level_5 | Expert opinion / mechanism-based reasoning |
| insufficient | Insufficient or conflicting evidence |

**Weight setting guide:**

| Range | Criteria |
|------|----------|
| 0.90 – 1.00 | Very strong evidence + high clinical utility (level_1a/1b) |
| 0.70 – 0.89 | Good evidence, frequently used (level_2a/2b) |
| 0.50 – 0.69 | Limited evidence or useful only in specific situations (level_3) |
| 0.30 – 0.49 | Insufficient evidence, adjunctive use (level_4) |
| 0.00 – 0.29 | Experimental or very limited use (level_5 / insufficient) |

---

## 4. Technique Steps (technique_steps)

> Write each step in the actual order the therapist performs them. Use technical medical terms followed by plain-language clarification in parentheses.

**Pre-procedure preparation:**

- Patient positioning:
- Therapist positioning:
- Contact area (therapist):
- Force direction:
- Pre-treatment explanation (to patient):

**Step-by-step procedure:**

1. (Preparation step — positioning)
2. (Contact step — hand/contact location)
3. (Execution step — force delivery method)
4. (Repetition / adjustment step — repetitions, grade adjustment)
5. (Assessment step — response check and reassessment)

**Per session recommendation:**

- Repetitions:
- Sets:
- Total treatment time:

---

## 5. Clinical Outcome Criteria

### Good response (good_response) — responses indicating the technique was applied effectively

-
-
-

### Caution response (caution_response) — responses requiring immediate check and adjustment

-
-

### Stop criteria (stop_criteria) — responses requiring immediate cessation of the technique

-
-

### Common mistakes and corrections (common_mistake)

| Common mistake | Correct approach |
|----------|-----------|
| | |
| | |

### Key clinical tips (clinical_notes)

> Maximum 3 lines, most important points only:

1.
2.
3.

---

## 6. Evidence References (key_references)

> Triple-verify all PMIDs using PubMed MCP. Confirm message, link, and metadata before citing. — Not required; omission is acceptable

| PMID | Title | Year | Journal | Study type | Key finding |
|------|------|------|------|----------|---------|
| | | | | RCT / SR / Cohort / Case report | |
| | | | | | |
| | | | | | |

---

## 7. Review Checklist

> Check all items before submission. Submission not allowed if any items are incomplete.

**Tag accuracy**
- [ ] Do all purpose_tags match the actual clinical indications?
- [ ] Do target_tags align with evidence and clinical experience?
- [ ] Are all absolute contraindications included in contraindication_tags without omission?

**Weight and evidence (not required)**
- [ ] Does recommendation_weight align with the evidence level?
- [ ] Are cited references primarily RCTs or systematic reviews?
- [ ] Have all PMIDs been triple-verified in PubMed?

**Technique description**
- [ ] Are the technique steps written with 5 or more steps in specific detail?
- [ ] Are patient positioning, therapist positioning, contact area, and force direction all documented?
- [ ] Are the recommended repetitions and sets per session specified?

**Clinical outcome criteria**
- [ ] Are 3 or more good responses documented?
- [ ] Are stop criteria clearly stated?
- [ ] Are 2 or more common mistakes documented along with corrections?

**KMO philosophy alignment**
- [ ] Does the content avoid explaining through the "pain = damage" frame?
- [ ] Is there no fear-inducing language for patients?
- [ ] Does it not conflict with the "the body is adaptive" perspective?
- [ ] Is there no mention of the KPM frame (postural imbalance, alignment abnormality)?

**Readability**
- [ ] Are plain-language clarifications provided alongside technical medical terms?
- [ ] Can a research staff member (not a therapist) understand the content?

---

_Author:_ | _Date:_ | _Reviewer:_ | _Review date:_
