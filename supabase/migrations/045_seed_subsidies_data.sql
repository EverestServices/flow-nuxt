-- Seed subsidies catalog with Hungarian support programs
INSERT INTO public.subsidies (name, description, target_group, discount_type, discount_value, sequence)
VALUES
  (
    'Otthonfelújítási Támogatás',
    'Az otthon energetikai korszerűsítésére igénybe vehető támogatás. A támogatás keretében napelem rendszer telepítése, szigetelés, nyílászáró csere és egyéb energetikai fejlesztések is támogathatók.',
    'Gyermeket nevelő családok',
    'percentage',
    50,
    1
  ),
  (
    'Napelem Pályázat',
    'Lakossági napelem és akkumulátor telepítésének támogatása. A támogatás fix összegű, amely csökkentheti a napelemes rendszer telepítésének költségeit.',
    'Magyar háztartások',
    'fixed',
    2800000,
    2
  ),
  (
    'Energetikai Korszerűsítési Program',
    'Komplex energetikai korszerűsítési támogatás régi építésű lakóingatlanok tulajdonosai számára. A támogatás felhasználható szigetelésre, fűtéskorszerűsítésre, nyílászáró cserére és megújuló energia rendszerek telepítésére.',
    'Régi építésű ingatlanok tulajdonosai',
    'percentage',
    35,
    3
  )
ON CONFLICT DO NOTHING;

-- Add comment
COMMENT ON TABLE public.subsidies IS 'Catalog of Hungarian subsidy programs for energy efficiency and renovation projects';
