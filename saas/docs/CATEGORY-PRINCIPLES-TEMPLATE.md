# [Category Name] Core Principles Research Sheet

<!-- owner: technique-researcher -->

> Completing this template will automatically populate the "Core Principles" card at the top of the Page 3 recommendation results.

---

## 1. Category Basic Information

| Field | Content |
|------|------|
| Category key (system) | joint_mobilization / mulligan / neurodynamics / soft_tissue / manipulation / ... |
| Korean name | |
| English name | |
| Key founder(s) | (e.g., Brian Mulligan, Geoffrey Maitland) |
| Core philosophy in one sentence | |
| UI subtitle | (e.g., Maitland Concept-based approach — displayed at the top of the Page 3 card) |

---

## 2. Core Principles (minimum 4, maximum 7)

> Principles the therapist must know before applying this approach. Order by importance.
> Displayed in the UI as icon + title + description (2-3 sentences).

### Principle 1 — [Title]

- **Icon**: (1 emoji — intuitively represents the nature of the principle)
- **Title**: (key phrase within ~10 characters — displayed in bold in the UI)
- **Description**: (2-3 sentences a therapist can understand immediately. Minimize medical jargon; when used, add plain-language clarification in parentheses)
- **Why it matters**: (what problems arise if this principle is ignored — internal reference only, not displayed in UI)

### Principle 2 — [Title]

- **Icon**:
- **Title**:
- **Description**:
- **Why it matters**:

### Principle 3 — [Title]

- **Icon**:
- **Title**:
- **Description**:
- **Why it matters**:

### Principle 4 — [Title]

- **Icon**:
- **Title**:
- **Description**:
- **Why it matters**:

### Principle 5 — Absolute Contraindications (required)

- **Icon**: ⚠️
- **Title**: Verify Absolute Contraindications
- **Description**: (List of situations in which this approach must not be applied. Be specific. State clearly without using fear-inducing language)
- **Why it matters**: Patient safety — failure to check contraindications can result in serious consequences such as neurological injury or worsening fractures

### Principle 6 — [Title] (optional)

- **Icon**:
- **Title**:
- **Description**:
- **Why it matters**:

### Principle 7 — [Title] (optional)

- **Icon**:
- **Title**:
- **Description**:
- **Why it matters**:

---

## 3. Ideal Patient Profile for This Approach

| Field | Content |
|------|------|
| Primary indications | |
| Ideal patient stage | acute / subacute / chronic (select applicable and provide rationale) |
| Symptoms where especially effective | |
| When this approach is not appropriate | |

---

## 4. Differences from Other Approaches

| Comparison approach | Difference | When to choose this approach |
|------------|--------|--------------------------|
| | | |
| | | |
| | | |

---

## 5. Key References / Textbooks

> Triple-verify all PMIDs using PubMed MCP. Confirm message, link, and metadata before citing.

| Title | Author | Year | Type | PMID (if applicable) |
|------|------|------|------|---------------|
| | | | Textbook / RCT / Systematic Review / Guideline | |
| | | | | |
| | | | | |

---

## 6. KMO Philosophy Alignment Check

- [ ] Does this content assume pain does not equal damage?
- [ ] Does it emphasize active patient participation?
- [ ] Is there no fear-avoidance-inducing language?
- [ ] Does it not conflict with the biopsychosocial perspective?
- [ ] Does it align with the "Calm things down, and build things back up" principle?
- [ ] Is there no mention of the KPM frame (postural imbalance, alignment abnormality)?

---

## 7. Code Integration Guide

After completing the principles, add them to the `APPROACH_PRINCIPLES` object in `prototype/index.html` using the format below:

```js
'[category key]': {
  title: '[Category Name] Core Principles',
  subtitle: '[UI subtitle]',
  principles: [
    { icon: '[emoji]', title: '[principle title]', desc: '[description 2-3 sentences]' },
    { icon: '[emoji]', title: '[principle title]', desc: '[description 2-3 sentences]' },
    { icon: '[emoji]', title: '[principle title]', desc: '[description 2-3 sentences]' },
    { icon: '[emoji]', title: '[principle title]', desc: '[description 2-3 sentences]' },
    { icon: '⚠️',      title: 'Verify Absolute Contraindications', desc: '[contraindication list]' },
    // Add principles 6-7 if needed (maximum 7)
  ]
}
```

**Category key list (current system):**

| Key | Korean name | Status |
|----|-----------|------|
| `joint_mobilization` | 관절가동술 | Complete |
| `mulligan` | 멀리건 기법 | In progress |
| `neurodynamics` | 신경가동술 | In progress |
| `soft_tissue` | 연부조직 가동술 | In progress |
| `manipulation` | 도수조작 | In progress |

---

_Author:_ | _Date:_ | _Reviewer (therapist host):_ | _Review date:_
