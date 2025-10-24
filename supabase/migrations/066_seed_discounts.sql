-- ============================================================================
-- Migration: Seed discounts
-- Description: Populates discounts table with default discount options
-- ============================================================================

-- Insert discounts
INSERT INTO public.discounts (persist_name, name, description, discount_type, value) VALUES
    (
        'autumn-2025',
        'Őszi kedvezmény 2025',
        'Elérhető minden ügyfél számára 2025 októberétől novemberéig terjedő időszakban.',
        'fixed',
        150000
    ),
    (
        'winter-2025-2026',
        'Téli kedvezmény 2025/2026',
        'Elérhető minden ügyfél számára 2025 decemberétől 2026 februárjáig terjedő időszakban.',
        'percentage',
        3
    ),
    (
        'battery-free',
        'Akkumulátor ingyen',
        'Napelem + Akkumulátor rendszer vásárlása esetén az akkumulátor ára ingyenes. A kedvezmény automatikusan kiszámításra kerül.',
        'calculated',
        0
    ),
    (
        'third-panel-free',
        'Harmadik panel ingyen',
        'Minden harmadik napelem panel ingyenes. A kedvezmény automatikusan kiszámításra kerül a kiválasztott panelek száma alapján.',
        'calculated',
        0
    )
ON CONFLICT (persist_name) DO NOTHING;

-- ============================================================================
-- END OF SEED DATA
-- ============================================================================
