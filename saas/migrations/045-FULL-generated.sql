-- ============================================================
-- 045-FULL-backfill-applicable-muscles.sql (자동 생성)
-- 생성 시각: 2026-05-01T08:33:22.529Z
-- 매칭: 174 / 비-근육: 163 / 미해결: 0
-- 실행 전 검토 필수. 미해결 기법은 별도 수동 UPDATE 필요.
-- ============================================================

BEGIN;

-- DTFM-Achilles 아킬레스건 심부마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"아킬레스건","muscle_en":"Achilles tendon"}]'::jsonb WHERE id = '00ecd665-c11a-41a5-82a7-9b6db7951477';
-- DFM-PatTend 슬개건 심부마찰 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"슬개건","muscle_en":"patellar tendon"}]'::jsonb WHERE id = '2f42a867-5614-402f-bc17-1660b7526627';
-- ART-TFLHip 대퇴근막장근 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"대퇴근막장근","muscle_en":"tensor fasciae latae"}]'::jsonb WHERE id = '1ccf18b4-57fe-40b5-bc1b-b5143c205c3a';
-- ART-AddHip 내전근군 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"내전근군","muscle_en":"adductors"}]'::jsonb WHERE id = 'cb2a909f-d793-4edf-b1f2-7a1c9248977b';
-- CTM-HipLateral 엉덩 관절 외측 결합조직 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"엉덩 관절 외측","muscle_en":"lateral hip region"}]'::jsonb WHERE id = '8f334cd9-107f-418e-9c6f-104cc1c8447d';
-- CTM-Gluteal 둔근 구역 결합조직 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"둔근","muscle_en":"gluteal muscles"}]'::jsonb WHERE id = 'c9301fd5-15bb-4b44-85db-dfbb75c006b5';
-- DFM-GTBursa 대전자 점액낭 주변 심부마찰 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"점액낭","muscle_en":"bursa"},{"muscle_ko":"대전자","muscle_en":"greater trochanter"}]'::jsonb WHERE id = '09b352a3-f68e-4071-9567-84eb152b7584';
-- Calf MFR 종아리 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"종아리","muscle_en":"calf (gastrocnemius·soleus)"}]'::jsonb WHERE id = 'f3d77137-cabc-4713-a612-dee2ef514981';
-- ART-Gastroc 장딴지근 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"장딴지근","muscle_en":"gastrocnemius"}]'::jsonb WHERE id = '8624f665-3ec3-49da-8bbe-4b304030a852';
-- ART-PlantarFascia 발바닥 근막 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"발바닥 근막","muscle_en":"plantar fascia"}]'::jsonb WHERE id = '6c6a7678-35d8-419d-a2a4-3b275945274b';
-- LumbCTM-LHJ 요추-고관절 이행부 결합조직 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"요추-고관절 이행부","muscle_en":"lumbo-hip transition"}]'::jsonb WHERE id = '6fe60cd1-d995-42cb-ba19-94854113e25c';
-- LumbCTM-Lat 요추 측방 결합조직 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"요추 측방","muscle_en":"lateral lumbar region"}]'::jsonb WHERE id = 'd0e9f7b3-551a-43d1-8441-4674dfe9f2b5';
-- DFM-MCL 내측측부인대 심부마찰 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"내측측부인대","muscle_en":"medial collateral ligament"}]'::jsonb WHERE id = '30f34b40-ca2b-4e41-ab79-7d79720bfd83';
-- LumbTrP-GluMed 중둔근 트리거포인트 압박
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"중둔근","muscle_en":"gluteus medius"}]'::jsonb WHERE id = '69c44fee-bace-4a8f-bdb9-27916b45c4b6';
-- DTFM-Plantar Fascia 발바닥 근막 기시부 심부마사지 (발꿈치 통증)
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"발바닥 근막","muscle_en":"plantar fascia"}]'::jsonb WHERE id = '6eee9530-e2a0-477c-a7fb-a0c65ce02b34';
-- DTFM-MCL 무릎 안쪽 인대 심부마사지 (내측 측부인대 손상)
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"내측 측부인대","muscle_en":"medial collateral ligament"}]'::jsonb WHERE id = 'a85f0049-9723-453e-a6ac-ee10ee14fa9b';
-- DTFM-Patellar Tendon 무릎뼈 아래 힘줄 심부마사지 (점퍼스 니)
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"무릎뼈 아래 힘줄","muscle_en":"patellar tendon"}]'::jsonb WHERE id = '70b15c6b-3f4e-4f26-84e5-0d975bf24165';
-- DTFM-Supraspinatus 어깨 가시위근 힘줄 심부마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"가시위근","muscle_en":"supraspinatus"}]'::jsonb WHERE id = 'e10483fb-0487-4f95-90d2-e41b8c865bc2';
-- KN-TrP-Poplit 슬와근 트리거포인트 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"슬와근","muscle_en":"popliteus"}]'::jsonb WHERE id = '8d48698d-2bfd-4d1e-8f99-996db5431860';
-- KN-TrP-SemiTend 반건양근 트리거포인트 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"반건양근","muscle_en":"semitendinosus"}]'::jsonb WHERE id = '1017a5d1-b165-4025-8eee-e2b82d18d3a6';
-- KN-TrP-BF 대퇴이두근 트리거포인트 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"대퇴이두근","muscle_en":"biceps femoris"}]'::jsonb WHERE id = '2f7bd59b-4506-46b4-8dcf-ba4d26d47985';
-- HS SCS 엉덩이·어깨 통증점 카운터스트레인
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"엉덩이","muscle_en":"gluteal region"}]'::jsonb WHERE id = '9d95c218-1b75-4e15-acf2-95a6e9c13a3c';
-- SCS-KN-GastMed 내측 비복근 스트레인-카운터스트레인
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"비복근","muscle_en":"gastrocnemius"}]'::jsonb WHERE id = '5dc75250-a1b6-4bce-8709-4cd5ee9c0bcc';
-- QL-TPR 허리네모근 트리거포인트 압박
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"허리네모근","muscle_en":"quadratus lumborum"}]'::jsonb WHERE id = 'da5349dd-4138-446a-8ad8-7fcd84546f5e';
-- LA SCS 허리 앞쪽 통증점 카운터스트레인
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"허리 앞쪽 통증점","muscle_en":"anterior lumbar tender point"}]'::jsonb WHERE id = 'afd22296-33a3-404f-b24f-f4f4f960d326';
-- LP SCS 허리 뒤쪽 통증점 카운터스트레인
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"허리 뒤쪽 통증점","muscle_en":"posterior lumbar tender point"}]'::jsonb WHERE id = 'ae3b78d0-1046-43be-82f2-d465a0bc2895';
-- SI SCS 엉치뼈·골반 통증점 카운터스트레인
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"엉치뼈","muscle_en":"sacrum"}]'::jsonb WHERE id = '51ec9121-cb91-4690-9bc6-756d5cf26743';
-- CTM-AB 배 결합조직 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"배","muscle_en":"abdomen"}]'::jsonb WHERE id = '481e14ef-7989-4842-8538-69569835e603';
-- ART-Piriformis 궁둥구멍근 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"궁둥구멍근","muscle_en":"piriformis"}]'::jsonb WHERE id = '7665ef91-8840-44c7-b6c7-a07f0aa67ae6';
-- ART-Iliopsoas 엉덩허리근 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"엉덩허리근","muscle_en":"iliopsoas"}]'::jsonb WHERE id = '7509a5d2-05fa-492c-b0be-8ad756a46d02';
-- ART-Hamstring 넙다리뒤근육 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"넙다리뒤근육","muscle_en":"hamstrings"}]'::jsonb WHERE id = '95ba013f-3806-4355-827e-1f50ccec538b';
-- ART-Quad 넙다리네갈래근 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"넙다리네갈래근","muscle_en":"quadriceps"}]'::jsonb WHERE id = '8d770ca9-e569-4bff-8e4a-86b3d25ba062';
-- CTM-SL 요추-천골 구역 결합조직 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"요추-천골","muscle_en":"lumbosacral region"}]'::jsonb WHERE id = '0f019f6d-de5f-4a06-83a5-04471b5a11ea';
-- CTM-SC 어깨·가슴 앞쪽 결합조직 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"어깨·가슴 앞쪽","muscle_en":"anterior shoulder/chest region"}]'::jsonb WHERE id = 'c6970434-143a-4c21-892a-7e385eac5da2';
-- DTFM-Lateral Epicondyle 팔꿈치 가쪽 뼈 돌출 부위 심부마사지 (테니스 엘보)
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"가쪽 뼈 돌출","muscle_en":"lateral epicondyle"}]'::jsonb WHERE id = '73b87d41-8ee0-4600-87bf-55ff9e081143';
-- DTFM-Medial Epicondyle 팔꿈치 안쪽 뼈 돌출 부위 심부마사지 (골프 엘보)
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"안쪽 뼈 돌출","muscle_en":"medial epicondyle"}]'::jsonb WHERE id = '48a9e08d-3e59-4392-bb92-4b1523346a82';
-- GAST-SOL-TPR 장딴지근·가자미근 트리거포인트 압박
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"가자미근","muscle_en":"soleus"},{"muscle_ko":"장딴지근","muscle_en":"gastrocnemius"}]'::jsonb WHERE id = 'b8304805-9b6b-469c-b7ae-3bd0047b0aa9';
-- WE-TrP 손목 폄근 트리거포인트 허혈성 압박 (아래팔 폄근)
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"아래팔 폄근","muscle_en":"forearm extensors"},{"muscle_ko":"손목 폄근","muscle_en":"wrist extensors"}]'::jsonb WHERE id = '9a6b440c-2692-41c6-afac-aff61119cf9c';
-- IS-TrP 가시아래근 트리거포인트 허혈성 압박
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"가시아래근","muscle_en":"infraspinatus"}]'::jsonb WHERE id = '58f327e4-6381-4f1d-b22f-6e8577931c0a';
-- HAM-TPR 넙다리뒤근육 트리거포인트 압박
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"넙다리뒤근육","muscle_en":"hamstrings"}]'::jsonb WHERE id = '31b3ccdf-41a3-4090-8146-02cf43650329';
-- TFL-TPR 넙다리근막긴장근 트리거포인트 압박
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"넙다리근막긴장근","muscle_en":"tensor fasciae latae"}]'::jsonb WHERE id = 'e65c9c40-831c-4c28-9b61-3718036d86ae';
-- IASTM-LevScap 견갑거근 IASTM
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"견갑거근","muscle_en":"levator scapulae"}]'::jsonb WHERE id = 'af51f0c1-bd84-4e63-b42b-d630071eef81';
-- IASTM-CervPost 경추 후방 근육군 IASTM
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"경추 후방","muscle_en":"posterior cervical region"}]'::jsonb WHERE id = '50abd8cc-f41b-4a87-8f9c-930d2fc7003c';
-- SH-MFR-PecMin 소흉근 근막이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"소흉근","muscle_en":"pectoralis minor"}]'::jsonb WHERE id = '28fe73ea-7353-4d6b-8c1c-e2ec1acde9e6';
-- SH-MFR-Supra 극상근 근막이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"극상근","muscle_en":"supraspinatus"}]'::jsonb WHERE id = 'e186dcc4-994d-4b2f-b8ae-80eb2908fee5';
-- SH-MFR-Infra 극하근·소원근 근막이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"극하근","muscle_en":"infraspinatus"},{"muscle_ko":"소원근","muscle_en":"teres minor"}]'::jsonb WHERE id = '61dddb4c-1aae-435e-b874-ae60712b8f1c';
-- SH-MFR-Sub 견갑하근 근막이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"견갑하근","muscle_en":"subscapularis"}]'::jsonb WHERE id = '9bad69fc-8059-4832-87f4-0647140faacf';
-- SH-MFR-Post 견갑대 후방 근막이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"견갑대 후방","muscle_en":"posterior shoulder girdle"}]'::jsonb WHERE id = '8ac78ead-34f7-4fad-ad02-ceb270286857';
-- ART-Supra 극상근 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"극상근","muscle_en":"supraspinatus"}]'::jsonb WHERE id = '681f31db-d005-41fa-bb0e-e93b2b561b50';
-- ART-Infra 극하근 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"극하근","muscle_en":"infraspinatus"}]'::jsonb WHERE id = '6a69aec7-aa82-487e-9fa3-8b2cde8241a8';
-- ART-Sub 견갑하근 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"견갑하근","muscle_en":"subscapularis"}]'::jsonb WHERE id = 'bf78837a-a7aa-4b1c-bb3d-643da86e9dbe';
-- ART-PecMin 소흉근 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"소흉근","muscle_en":"pectoralis minor"}]'::jsonb WHERE id = 'db1b7096-27e2-45b7-b2a0-03ba1207a57e';
-- ART-TricepsLH 삼두근 장두 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"삼두근","muscle_en":"triceps brachii"}]'::jsonb WHERE id = '00792464-4043-47ce-b34b-d13e4e035d9f';
-- CTM-Periscap 견갑골 주변 결합조직 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"견갑골","muscle_en":"scapula"}]'::jsonb WHERE id = '0bf0e13a-0316-4066-b52e-3d2cb62c18ea';
-- CTM-ShAnterior 견관절 전방 결합조직 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"견관절 전방","muscle_en":"anterior glenohumeral region"}]'::jsonb WHERE id = 'df88b8bd-a55f-4f79-840b-2555bf88a0c1';
-- CTM-ShPosterior 견관절 후방 결합조직 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"견관절 후방","muscle_en":"posterior glenohumeral region"}]'::jsonb WHERE id = 'd2d9ee28-4de8-4420-b87d-49b007385dda';
-- DFM-SupraTend 극상근건 심부마찰 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"극상근","muscle_en":"supraspinatus"}]'::jsonb WHERE id = '92670bf1-1a28-4eb8-8879-a0440709a72f';
-- DFM-BicepsTend 이두박근 장두건 심부마찰 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"이두박근","muscle_en":"biceps brachii"}]'::jsonb WHERE id = '6c5a78bd-e803-460e-b3bc-7c460a93d0a9';
-- DFM-Subacromial 견봉하 점액낭 주변 심부마찰 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"점액낭","muscle_en":"bursa"},{"muscle_ko":"견봉하","muscle_en":"subacromial"}]'::jsonb WHERE id = 'a601431f-3359-43a1-a141-0e7aeec0cb49';
-- DFM-ACJCap 견봉쇄골관절 관절낭 심부마찰 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"견봉쇄골관절","muscle_en":"acromioclavicular joint"},{"muscle_ko":"관절낭","muscle_en":"joint capsule"}]'::jsonb WHERE id = 'a2d05a05-07f6-4d90-a846-2e915fb7666e';
-- SH-TrP-Supra 극상근 트리거포인트 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"극상근","muscle_en":"supraspinatus"}]'::jsonb WHERE id = '2d396b53-f0a9-4557-a686-96e938575682';
-- SH-TrP-Infra 극하근 트리거포인트 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"극하근","muscle_en":"infraspinatus"}]'::jsonb WHERE id = 'cf477395-a571-4d41-8f3b-ac4e2586efc7';
-- SH-TrP-TMin 소원근 트리거포인트 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"소원근","muscle_en":"teres minor"}]'::jsonb WHERE id = '5cc47593-dbbc-42fb-a622-183cd5d2dcce';
-- LumbIASTM-ES 요추 척추세움근 IASTM
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"척추세움근","muscle_en":"erector spinae"},{"muscle_ko":"요추","muscle_en":"lumbar region"}]'::jsonb WHERE id = 'da3cb45c-5b9a-4ea5-ac98-c6755a7ad75d';
-- LumbIASTM-MF 요추 다열근 IASTM
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"다열근","muscle_en":"multifidus"},{"muscle_ko":"요추","muscle_en":"lumbar region"}]'::jsonb WHERE id = '1f734be4-3078-450a-8cd5-e81c6939cf98';
-- SH-TrP-Sub 견갑하근 트리거포인트 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"견갑하근","muscle_en":"subscapularis"}]'::jsonb WHERE id = '9645425b-3303-4d8a-95bb-340f78797a1d';
-- SH-TrP-PecMin 소흉근 트리거포인트 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"소흉근","muscle_en":"pectoralis minor"}]'::jsonb WHERE id = 'f5078de4-cb4d-4092-b486-cb3fb21addc0';
-- SH-TrP-Delt 삼각근 트리거포인트 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"삼각근","muscle_en":"deltoid"}]'::jsonb WHERE id = '93bad33b-9438-43a8-becc-dc339a4bc081';
-- KN-MFR-Quad 대퇴사두근 근막이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"대퇴사두근","muscle_en":"quadriceps"}]'::jsonb WHERE id = '27b4551e-a833-4e44-8f13-2aef24cdd2bb';
-- KN-MFR-Ham 슬굴곡근 근막이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"슬굴곡근","muscle_en":"hamstrings"}]'::jsonb WHERE id = 'e7033ddb-7fa9-426d-a7b0-45d0cd298cd4';
-- ART-ITB 장경인대 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"장경인대","muscle_en":"iliotibial band"}]'::jsonb WHERE id = 'e4a9b0ac-9f82-4802-94c4-82da58363e55';
-- KN-MFR-ITB 장경인대 근막이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"장경인대","muscle_en":"iliotibial band"}]'::jsonb WHERE id = 'bed39774-3b98-4db9-b92a-58f52caf9fe9';
-- KN-MFR-GastSol 비복근·가자미근 근막이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"가자미근","muscle_en":"soleus"},{"muscle_ko":"비복근","muscle_en":"gastrocnemius"}]'::jsonb WHERE id = '15cf4dab-2eba-43f7-b046-3469bba67879';
-- ART-QuadKnee 대퇴사두근 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"대퇴사두근","muscle_en":"quadriceps"}]'::jsonb WHERE id = 'fb8bce1b-6b0b-4f4c-828c-c5558ef9d068';
-- ART-HamKnee 슬굴곡근 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"슬굴곡근","muscle_en":"hamstrings"}]'::jsonb WHERE id = '6871e738-9bb6-432d-8787-2d783f456d15';
-- Proximal ITB / TFL MFR 골반 바깥쪽 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"골반 바깥쪽","muscle_en":"lateral pelvis"}]'::jsonb WHERE id = '6e34e66d-06cb-4350-ba6e-46990f46c461';
-- ART-Poplit 슬와근 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"슬와근","muscle_en":"popliteus"}]'::jsonb WHERE id = '9cd6b03a-f84c-430c-80f9-c15b263c75c2';
-- CTM-KneeAnterior 무릎 전방 결합조직 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"무릎 전방","muscle_en":"anterior knee region"}]'::jsonb WHERE id = '82a0518d-2874-4690-bc44-130d6293d65c';
-- CTM-KneePosterior 무릎 후방 결합조직 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"무릎 후방","muscle_en":"posterior knee region"}]'::jsonb WHERE id = '6a977f80-c07d-4bdf-8c11-e7876bdbfae3';
-- DFM-LCL 외측측부인대 심부마찰 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"외측측부인대","muscle_en":"lateral collateral ligament"}]'::jsonb WHERE id = '8c7b3666-0581-4a9a-a5da-7c17cfb7d4b4';
-- DFM-PoplitTend 슬와근건 심부마찰 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"슬와근","muscle_en":"popliteus"}]'::jsonb WHERE id = 'aee262e7-1fd3-4787-98ac-1d024be78bde';
-- KN-TrP-RF 대퇴직근 트리거포인트 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"대퇴직근","muscle_en":"rectus femoris"}]'::jsonb WHERE id = '8af7568b-33d4-4321-a94d-da87b33324cb';
-- KN-TrP-VMO 내측광근(VMO) 트리거포인트 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"내측광근","muscle_en":"vastus medialis"}]'::jsonb WHERE id = '6c339047-7d61-400f-9a8f-dcdb6b5f18b5';
-- LumbART-ES 요추 척추세움근 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"척추세움근","muscle_en":"erector spinae"},{"muscle_ko":"요추","muscle_en":"lumbar region"}]'::jsonb WHERE id = 'f0f02f52-50d1-4550-8a2a-7554ca811e0a';
-- LumbART-MF 요추 다열근 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"다열근","muscle_en":"multifidus"},{"muscle_ko":"요추","muscle_en":"lumbar region"}]'::jsonb WHERE id = '9a9ba4bc-b3d0-4962-a60e-fcd665260e1c';
-- HIP-MFR-Psoas 장요근 근막이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"장요근","muscle_en":"iliopsoas"}]'::jsonb WHERE id = '507b56c5-5a09-4583-9834-542657f52fb0';
-- HIP-MFR-Pir 이상근 근막이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"이상근","muscle_en":"piriformis"}]'::jsonb WHERE id = 'ec9d59e9-b11c-403f-afec-176b43ff8516';
-- HIP-MFR-TFL 대퇴근막장근 근막이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"대퇴근막장근","muscle_en":"tensor fasciae latae"}]'::jsonb WHERE id = '45d48d6a-323f-4ae3-ba48-2fa854f852cb';
-- HIP-MFR-Add 내전근군 근막이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"내전근군","muscle_en":"adductors"}]'::jsonb WHERE id = 'b9bf42b4-3619-4993-9a46-936df69a26c6';
-- HIP-MFR-GluMed 중둔근·소둔근 근막이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"중둔근","muscle_en":"gluteus medius"},{"muscle_ko":"소둔근","muscle_en":"gluteus minimus"}]'::jsonb WHERE id = 'a486500a-461e-490f-abaf-0b331004aa56';
-- ART-PsoasHip 장요근 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"장요근","muscle_en":"iliopsoas"}]'::jsonb WHERE id = '606bb9ef-7eb6-456c-9f93-150d05929322';
-- ART-PirHip 이상근 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"이상근","muscle_en":"piriformis"}]'::jsonb WHERE id = '36b6a25f-acbb-410d-a5e3-a0cc6fa45fc5';
-- LumbART-IP 장요근 능동 이완 기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"장요근","muscle_en":"iliopsoas"}]'::jsonb WHERE id = 'c39cb605-6beb-4bcd-9ccb-41e5f47bdc71';
-- Lumbar MFR 요추 근막이완 기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"요추","muscle_en":"lumbar region"}]'::jsonb WHERE id = '4e6443b7-de0f-425a-9c1d-7322f41e93fc';
-- TLF MFR 흉요근막 이완 기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"흉요근막","muscle_en":"thoracolumbar fascia"}]'::jsonb WHERE id = 'be7267ca-7f10-4d8a-b52b-6882c5ab08a4';
-- LumbMFR-LPJ 요추-골반 이행부 근막이완 기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"요추-골반 이행부","muscle_en":"lumbopelvic junction"}]'::jsonb WHERE id = 'da99fbf9-cbb4-434e-879b-ddc726f00eea';
-- LumbMFR-Pir 이상근 근막이완 기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"이상근","muscle_en":"piriformis"}]'::jsonb WHERE id = '981fedfa-a868-44fe-8ddc-4a12925fe599';
-- LumbMFR-Psoas 장요근 근막이완 기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"장요근","muscle_en":"iliopsoas"}]'::jsonb WHERE id = '929f3fcf-43c7-47a5-984e-4a0088e30adf';
-- CTM-HipAnterior 엉덩 관절 전방 결합조직 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"엉덩 관절 전방","muscle_en":"anterior hip region"}]'::jsonb WHERE id = '714d4fa1-f02e-458e-b85d-933e76d9a825';
-- Plantar MFR 발바닥 근막 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"발바닥 근막","muscle_en":"plantar fascia"}]'::jsonb WHERE id = '99d6ba92-bdb9-4fdf-a73e-41ce5d913a01';
-- Forearm Extensor MFR 아래팔(전완) 폄근(신전근) 근막 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"아래팔(전완) 폄근(신전근)","muscle_en":"forearm extensors"}]'::jsonb WHERE id = '4ea2b7b7-aa33-4c77-8baa-efa1e90fbd32';
-- Forearm Flexor MFR 아래팔(전완) 굽힘근(굴곡근) 근막 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"아래팔(전완) 굽힘근(굴곡근)","muscle_en":"forearm flexors"}]'::jsonb WHERE id = 'e61ac89c-a312-4b6d-aef8-349d6b8813cf';
-- Gluteal MFR 엉덩이 근막 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"엉덩이","muscle_en":"gluteal region"}]'::jsonb WHERE id = '981eda79-a60a-4be6-8192-c2d885d5d984';
-- Quad MFR 허벅지 앞쪽 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"허벅지 앞쪽","muscle_en":"anterior thigh (quadriceps)"}]'::jsonb WHERE id = 'b2f10e33-c337-4f5e-82e9-22c505342468';
-- Anterior Shoulder MFR 어깨 앞쪽 근막 이완 (가슴·어깨 연결부)
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"어깨 앞쪽","muscle_en":"anterior shoulder region"}]'::jsonb WHERE id = '63296608-262e-4b57-9d95-0855622f9bf0';
-- Posterior Shoulder MFR 어깨 뒤쪽 근막 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"어깨 뒤쪽","muscle_en":"posterior shoulder region"}]'::jsonb WHERE id = '03eaed38-329e-4f7d-91d8-c67f32469d4c';
-- DFM-HipCapAnt 엉덩 관절 전방 관절낭 심부마찰 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"엉덩 관절 전방","muscle_en":"anterior hip region"},{"muscle_ko":"관절낭","muscle_en":"joint capsule"}]'::jsonb WHERE id = '832cb507-392f-4589-8cfb-a0498dcf930e';
-- DFM-SacrTub 천결절인대 심부마찰 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"천결절인대","muscle_en":"sacrotuberous ligament"}]'::jsonb WHERE id = '7642a836-d8a7-4c04-be16-4367a01dd8f5';
-- CTM-LF 종아리·발 결합조직 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"종아리","muscle_en":"calf (gastrocnemius·soleus)"}]'::jsonb WHERE id = '1aed5a3b-ce99-4803-ba95-a68227bab0ff';
-- GMED-TPR 중간볼기근 트리거포인트 압박
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"중간볼기근","muscle_en":"gluteus medius"}]'::jsonb WHERE id = 'e8a39d2c-f611-4342-9a11-a2eb7270e90a';
-- PIR-TPR 궁둥구멍근 트리거포인트 압박
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"궁둥구멍근","muscle_en":"piriformis"}]'::jsonb WHERE id = 'ed6b1f91-056d-470a-9991-37bb2f9eff28';
-- HIP-TrP-Psoas 장요근 트리거포인트 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"장요근","muscle_en":"iliopsoas"}]'::jsonb WHERE id = 'b9cbe6ab-cba7-483b-8756-de889be7ca4f';
-- HIP-TrP-Pir 이상근 트리거포인트 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"이상근","muscle_en":"piriformis"}]'::jsonb WHERE id = 'ba694128-c28b-4ce4-85de-3b20fd84e200';
-- ART-Ext 아래팔 폄근 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"아래팔 폄근","muscle_en":"forearm extensors"}]'::jsonb WHERE id = 'd39dff97-8bfc-4f62-b2c4-ddc0eb7bed9c';
-- ART-Flex 아래팔 굽힘근 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"아래팔 굽힘근","muscle_en":"forearm flexors"}]'::jsonb WHERE id = '2542458d-5d33-4efe-afdb-e6ad5038b333';
-- HIP-TrP-TFL 대퇴근막장근 트리거포인트 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"대퇴근막장근","muscle_en":"tensor fasciae latae"}]'::jsonb WHERE id = 'f7b91722-a1dc-49cc-862a-a42274350b2b';
-- HIP-TrP-GluMed 중둔근 트리거포인트 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"중둔근","muscle_en":"gluteus medius"}]'::jsonb WHERE id = '575a9ba6-1c31-4c32-8add-622ebaf50b0a';
-- HIP-TrP-GluMax 대둔근 트리거포인트 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"대둔근","muscle_en":"gluteus maximus"}]'::jsonb WHERE id = 'c135b3b0-8f77-4740-b20a-691fcabe1c3f';
-- HIP-TrP-Add 내전근 트리거포인트 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"내전근","muscle_en":"adductors"}]'::jsonb WHERE id = '922a5834-0ef4-42c9-96c9-05a3239c6881';
-- ART-Pec Minor 작은가슴근 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"작은가슴근","muscle_en":"pectoralis minor"}]'::jsonb WHERE id = 'f6cdd79a-4484-44a4-9e5d-af63f99fd97c';
-- ART-RC 어깨 회전근개 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"회전근개","muscle_en":"rotator cuff"}]'::jsonb WHERE id = '64b22246-fb23-4ae4-89fb-3d6bb2c67dfe';
-- ANK-MFR-GastSol 비복근·가자미근 근막이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"가자미근","muscle_en":"soleus"},{"muscle_ko":"비복근","muscle_en":"gastrocnemius"}]'::jsonb WHERE id = '6cd967a9-d57a-47ed-85d2-98fdd52fe114';
-- ANK-MFR-PlantFas 족저근막 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"족저근막","muscle_en":"plantar fascia"}]'::jsonb WHERE id = '606e25bd-a408-48f0-a995-6c3c91db39c4';
-- ANK-MFR-Achilles 아킬레스건 주변 근막이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"아킬레스건","muscle_en":"Achilles tendon"}]'::jsonb WHERE id = '033a6785-e22f-4f1e-b507-923ce51f11cf';
-- ANK-MFR-Peron 비골근 근막이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"비골근","muscle_en":"peroneals"}]'::jsonb WHERE id = '626354ba-d69b-446b-8a57-46797f71da48';
-- ART-GastAnkle 비복근 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"비복근","muscle_en":"gastrocnemius"}]'::jsonb WHERE id = 'cb89d8fd-ddbc-48c2-a672-e9854961a7de';
-- ART-PeronAnkle 비골근 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"비골근","muscle_en":"peroneals"}]'::jsonb WHERE id = 'fe616014-1b57-47bc-945b-e6213f580529';
-- ART-TibAnt 전경골근 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"전경골근","muscle_en":"tibialis anterior"}]'::jsonb WHERE id = 'd54de9aa-ad4c-4c1c-a57f-4c30e71fcffb';
-- CTM-AnkleAnterior 발목 전방 결합조직 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"발목 전방","muscle_en":"anterior ankle region"}]'::jsonb WHERE id = '32118634-09cb-49fb-99da-0d589e767352';
-- CTM-AnklePosterior 발목 후방·아킬레스 결합조직 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"발목 후방","muscle_en":"posterior ankle region"},{"muscle_ko":"아킬레스","muscle_en":"Achilles region"}]'::jsonb WHERE id = '86c3a168-f2c8-4f71-9c4e-a5203de71b20';
-- DFM-AchillesTend 아킬레스건 심부마찰 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"아킬레스건","muscle_en":"Achilles tendon"}]'::jsonb WHERE id = '55118dc6-7589-4523-8e05-75e13cad2133';
-- DFM-PlantFasDFM 족저근막 심부마찰 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"족저근막","muscle_en":"plantar fascia"}]'::jsonb WHERE id = '01f6d331-4aa5-4901-bb4e-ff78bdab307e';
-- DFM-ATFL 전거비인대 심부마찰 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"전거비인대","muscle_en":"anterior talofibular ligament"}]'::jsonb WHERE id = 'c4cefd82-c898-4a27-a3d5-f2fad7834bbd';
-- DFM-CFL 종비인대 심부마찰 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"종비인대","muscle_en":"calcaneofibular ligament"}]'::jsonb WHERE id = 'b3cb5421-2d8f-4f5e-88b9-4418cdff8e2c';
-- ANK-TrP-Gast 비복근 트리거포인트 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"비복근","muscle_en":"gastrocnemius"}]'::jsonb WHERE id = '00346f58-0ea9-44b5-bcdd-c833abc4c820';
-- ANK-TrP-Sol 가자미근 트리거포인트 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"가자미근","muscle_en":"soleus"}]'::jsonb WHERE id = '70d860b3-dfd6-4da2-a8e7-609c7ae6b233';
-- ANK-TrP-Peron 비골근 트리거포인트 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"비골근","muscle_en":"peroneals"}]'::jsonb WHERE id = '656cfa12-b863-4b0a-9c03-7d686154f7f4';
-- ANK-TrP-TibAnt 전경골근 트리거포인트 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"전경골근","muscle_en":"tibialis anterior"}]'::jsonb WHERE id = 'e48148d9-f59a-4eed-bb2e-70dec3fe038b';
-- ANK-TrP-Plantar 족저 내재근 트리거포인트 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"족저 내재근","muscle_en":"plantar intrinsic muscles"}]'::jsonb WHERE id = '5ccbf8fa-f992-4629-b933-f91ce6e5b525';
-- SCS-SH-Supra 극상근 스트레인-카운터스트레인
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"극상근","muscle_en":"supraspinatus"}]'::jsonb WHERE id = '513a0fa7-681e-4e90-8b13-8cd66472fbbd';
-- SCS-SH-Infra 극하근 스트레인-카운터스트레인
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"극하근","muscle_en":"infraspinatus"}]'::jsonb WHERE id = 'd78c4249-a433-4752-a248-801bc0d38836';
-- Hamstring MFR 허벅지 뒤쪽 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"허벅지 뒤쪽","muscle_en":"posterior thigh (hamstrings)"}]'::jsonb WHERE id = '9bfffbb8-9893-41ef-9a65-7896a64203da';
-- ITB MFR IT밴드 이완 (허벅지 바깥쪽 띠 이완)
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"허벅지 바깥쪽","muscle_en":"lateral thigh (ITB·TFL)"},{"muscle_ko":"IT밴드","muscle_en":"iliotibial band"}]'::jsonb WHERE id = 'c89009fd-e280-4923-8f68-81ca06422173';
-- Scapular MFR 날개뼈(견갑골) 주변 근막 이완
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"날개뼈","muscle_en":"scapula"},{"muscle_ko":"견갑골","muscle_en":"scapula"}]'::jsonb WHERE id = '4f56c909-ae0d-4cad-a7e0-d3caeeb6f9b3';
-- LumbART-QL 허리네모근 능동 이완 기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"허리네모근","muscle_en":"quadratus lumborum"}]'::jsonb WHERE id = 'e9ccd320-e804-4a73-a86d-2e6beedf307c';
-- ART-CervMultifidus 경추 다열근 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"다열근","muscle_en":"multifidus"}]'::jsonb WHERE id = '96568e64-571f-46e8-9221-9224205a12e2';
-- ART-LevScap 견갑거근 능동적 이완기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"견갑거근","muscle_en":"levator scapulae"}]'::jsonb WHERE id = '60e41dd5-17dd-410a-aa66-8802599b9d96';
-- CTM-TB 등 상부·중부 결합조직 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"등 상부","muscle_en":"upper thoracic region"}]'::jsonb WHERE id = '6ad9ba45-9711-401e-81bb-572b596d0a4b';
-- CTM-CTJ 경추-흉추 이행부 결합조직 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"경추-흉추 이행부","muscle_en":"cervicothoracic junction"}]'::jsonb WHERE id = '89e21e30-091c-4f4a-a3b8-c76295b242ff';
-- CTM-CervLateral 경추 측방 결합조직 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"경추 측방","muscle_en":"lateral cervical region"}]'::jsonb WHERE id = 'f1bbf8cf-4cb3-406c-afda-2014a05f71da';
-- CTM-HL 엉덩이·허벅지 바깥쪽 결합조직 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"허벅지 바깥쪽","muscle_en":"lateral thigh (ITB·TFL)"},{"muscle_ko":"엉덩이","muscle_en":"gluteal region"}]'::jsonb WHERE id = 'e0b63115-6156-40b3-854c-19de22325cf9';
-- DFM-CervFacet 경추 후관절 관절낭 심부마찰 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"관절낭","muscle_en":"joint capsule"},{"muscle_ko":"후관절","muscle_en":"facet joint"}]'::jsonb WHERE id = '1101a6a2-6712-4a6a-be54-26c6685d382e';
-- DTFM-CTJ 경추-흉추 이행부 심부마찰 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"경추-흉추 이행부","muscle_en":"cervicothoracic junction"}]'::jsonb WHERE id = 'eb8d299a-0b51-4232-bb53-4b1aa34e27fc';
-- LumbDFM-ILL 장골요추 인대 심부마찰 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"장골요추 인대","muscle_en":"iliolumbar ligament"}]'::jsonb WHERE id = '4d744e52-29b8-4282-8b68-e0396f2061a6';
-- LumbDFM-Lig 요추 인대 심부 마찰 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"요추 인대","muscle_en":"lumbar ligaments"}]'::jsonb WHERE id = '0ff5f997-5831-442a-b230-883a81f0e7cc';
-- CervMult-TrP 경추 다열근 트리거포인트 압박
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"다열근","muscle_en":"multifidus"}]'::jsonb WHERE id = '80c7fd9b-644d-4d2a-b6ca-06d4fc0eebf0';
-- LevScap-TrP 견갑거근 트리거포인트 압박
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"견갑거근","muscle_en":"levator scapulae"}]'::jsonb WHERE id = '3da02920-53c1-4b70-a37c-21ab52586951';
-- Scalenes-TrP 사각근 트리거포인트 압박
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"사각근","muscle_en":"scalenes"}]'::jsonb WHERE id = 'c621e865-3439-4f7a-a326-c20d8f1e9ab2';
-- LumbTrP-IL 장늑근 트리거포인트 압박
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"장늑근","muscle_en":"iliocostalis"}]'::jsonb WHERE id = 'fb87db77-0502-4ba0-b41f-cc8f7275cf27';
-- LumbTrP-MF 요추 다열근 트리거포인트 압박
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"다열근","muscle_en":"multifidus"},{"muscle_ko":"요추","muscle_en":"lumbar region"}]'::jsonb WHERE id = '72039ab5-9925-4f8a-8601-946dd837e39c';
-- LumbTrP-Pir 이상근 트리거포인트 압박
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"이상근","muscle_en":"piriformis"}]'::jsonb WHERE id = '48972da0-5b6c-4081-b007-31fa49b9ddc0';
-- T/Rib SCS 등·갈비뼈 통증점 카운터스트레인
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"갈비뼈","muscle_en":"rib"}]'::jsonb WHERE id = '20eeb510-be5e-4006-b4bc-931c0696899b';
-- CervART-SCM 흉쇄유돌근 능동 이완 기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"흉쇄유돌근","muscle_en":"sternocleidomastoid"}]'::jsonb WHERE id = '1a05b570-b166-4a5c-9ee0-9d6b88321d84';
-- CervART-UT 상부 승모근 능동 이완 기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"상부 승모근","muscle_en":"upper trapezius"}]'::jsonb WHERE id = '412f1b4c-d880-46d1-8feb-a68125fc72c0';
-- CervART-LS 견갑거근 능동 이완 기법
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"견갑거근","muscle_en":"levator scapulae"}]'::jsonb WHERE id = 'fde9af46-0c66-45b4-b9df-c3a17235e19d';
-- CervDF-FC 경추 후관절 관절낭 심부 마찰 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"관절낭","muscle_en":"joint capsule"},{"muscle_ko":"후관절","muscle_en":"facet joint"}]'::jsonb WHERE id = '2b1a01a4-4481-4615-9e71-f8b2f7b9d80c';
-- CervDF-SOC 후두하근 심부 마찰 마사지
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"후두하근","muscle_en":"suboccipital muscles"}]'::jsonb WHERE id = '3cffa904-292e-42af-bbbc-45c0658f1614';
-- CervTP-SOC 후두하근 트리거포인트 치료
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"후두하근","muscle_en":"suboccipital muscles"}]'::jsonb WHERE id = '290ee1b0-d27d-4e89-bf62-38dce75d3860';
-- CervTP-UT 상부 승모근 트리거포인트 치료
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"상부 승모근","muscle_en":"upper trapezius"}]'::jsonb WHERE id = '66ed5d27-3513-480b-b6f1-021ed34d9a2d';
-- LumbTP-QL 요방형근 트리거포인트 치료
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"요방형근","muscle_en":"quadratus lumborum"}]'::jsonb WHERE id = 'b1488520-b5bd-4fb1-8951-84d8d482959e';
-- LumbTP-PIR 이상근 트리거포인트 치료
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"이상근","muscle_en":"piriformis"}]'::jsonb WHERE id = 'f3a1365e-cba5-45ca-a62f-29047ca39314';
-- SCS-SH-Sub 견갑하근 스트레인-카운터스트레인
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"견갑하근","muscle_en":"subscapularis"}]'::jsonb WHERE id = 'f7cc8ea0-aab7-400a-b7ab-a5ebc9f74acd';
-- SCS-KN-RF 대퇴직근 스트레인-카운터스트레인
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"대퇴직근","muscle_en":"rectus femoris"}]'::jsonb WHERE id = 'c9132b63-f08b-440d-8ece-12701c5537c6';
-- SCS-KN-Poplit 슬와근 스트레인-카운터스트레인
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"슬와근","muscle_en":"popliteus"}]'::jsonb WHERE id = 'f678124a-a91b-474d-ac94-7b363a2e3b44';

COMMIT;
