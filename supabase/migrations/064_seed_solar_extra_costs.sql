-- ============================================================================
-- Migration: Seed solar extra costs
-- Description: Populates extra_costs table with solar panel extra costs
-- ============================================================================

-- Insert solar extra costs
INSERT INTO public.extra_costs (persist_name, name, description, price, is_quantity_based, category) VALUES
    -- General
    ('scaffolding-5-8m', 'Állványozás 5-8 méter magasságú tetőkhöz', 'Állványozási költség 5-8 méter közötti magasságú tetőkhöz', 150000, false, 'general'),
    ('scaffolding-above-8m', 'Állványozás 8 méter feletti tetőkhöz', 'Állványozási költség 8 méter feletti magasságú tetőkhöz', 250000, false, 'general'),
    ('roof-gradient-35', 'Tetőhajlás 35° felett', 'Pótdíj 35 fokot meghaladó tetőhajlás esetén', 80000, false, 'general'),
    ('material-2-strings-15-panels', 'Anyag 2 string alatt 15 panel alá', 'Pótanyag költség 15 panel alatti kis rendszerekhez', 45000, false, 'general'),

    -- Connections
    ('single-phase-dhw-connections', 'Egyfázisú HMV csatlakozások száma', 'Egyfázisú használati melegvíz csatlakozások', 25000, true, 'connections'),
    ('three-phase-dhw-connections', 'Háromfázisú HMV csatlakozások száma', 'Háromfázisú használati melegvíz csatlakozások', 45000, true, 'connections'),

    -- Electric meter
    ('electric-meter-movement', 'Villanyóra mozgatása', 'Villanyóra áthelyezése új helyre', 120000, false, 'electric_meter'),
    ('electric-meter-main-breaker', 'Villanyóra rekonstrukció - főkapcsoló cseréje', 'Villanyóra mérőhely rekonstrukciója főkapcsoló cserével', 85000, false, 'electric_meter'),
    ('electric-meter-hdo-breaker', 'Villanyóra rekonstrukció - HDO kapcsoló cseréje', 'Villanyóra mérőhely rekonstrukciója HDO kapcsoló cserével', 65000, false, 'electric_meter'),
    ('electric-meter-simple', 'Villanyóra mérőhely rekonstrukció - egyszerű', 'Egyszerű villanyóra mérőhely rekonstrukció', 55000, false, 'electric_meter'),
    ('electric-meter-ppds-relay', 'Villanyóra mérőhely módosítás - PPDS relé-kapcsoló szerint', 'Mérőhely módosítás PPDS relé-kapcsoló előírások szerint', 95000, false, 'electric_meter'),

    -- Lightning protection
    ('main-protection-busbar', 'Fő védővezeték kialakítása', 'Főpotenciál kiegyenlítő vezeték kialakítása', 75000, false, 'lightning_protection'),
    ('lightning-protection-revision', 'Meglévő villámvédelem felülvizsgálata', 'Meglévő villámvédelmi rendszer szakmai felülvizsgálata', 45000, false, 'lightning_protection'),

    -- Cables
    ('additional-ac-cabling', 'Pótlólagos AC kábelezés /m - 20 méter felett', 'AC kábelezés 20 méteren felüli hosszra méterenként', 3500, true, 'cables'),
    ('additional-dc-cabling', 'Pótlólagos DC kábelezés /m - 20 méter felett', 'DC kábelezés 20 méteren felüli hosszra méterenként', 2800, true, 'cables'),
    ('additional-dc-cabling-second-string', 'Pótlólagos DC kábelezés /m - 20 méter felett második stringhez', 'DC kábelezés második stringhez 20 méteren felüli hosszra méterenként', 2800, true, 'cables'),

    -- Backup
    ('backup-simple', 'Backup (Egyszerű)', 'Egyszerű backup funkció kialakítása', 180000, false, 'backup'),
    ('backup-three-phase', 'Backup funkció (3-fázisú)', 'Háromfázisú backup funkció kialakítása', 320000, false, 'backup'),

    -- Internet
    ('internet-cable', 'Internet kábel', 'Internet kábel kiépítése a rendszer monitorozásához', 25000, false, 'internet'),
    ('powerline-adapter', 'Powerline adapter', 'Powerline adapter a hálózati kommunikációhoz', 35000, false, 'internet')
ON CONFLICT (persist_name) DO NOTHING;

-- ============================================================================
-- END OF SEED DATA
-- ============================================================================
