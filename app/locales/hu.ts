export default {
  surveyFields: {
    general: {
      sectionName: 'Általános adatok',
      propertyType: 'Ingatlan típusa',
      constructionYear: 'A lakás/ház építési éve',
      winterTemperature: 'Lakás téli belső hőmérséklete',
      mainOrientation: 'Az ingatlan fő életterének tájolása',
      buildingStories: 'Hány szintes az ingatlan?',
      hasBasement: 'Pincével rendelkezik?',
      hasAttic: 'Beépített tetőtérrel rendelkezik?'
    },
    floors: {
      sectionName: 'Szintek adatai',
      floorArea: 'szint alapterülete',
      heatedArea: 'Ebből fűtött belső alapterület',
      ceilingHeight: 'Belmagasság'
    },
    walls: {
      sectionName: 'Falak',
      wallTypesCount: 'Külső falak típusa',
      wallType: 'Fal típusa',
      wallThickness: 'Fal vastagsága',
      wallSurfaceRatio: 'Falfelület aránya',
      wallInsulation: 'Hőszigetelés',
      wallWarning: 'Amennyiben több különböző faltípus van az épületben, kérjük, a legnagyobb arányban előforduló faltípust adja meg.'
    },
    roof: {
      sectionName: 'Tető',
      roofType: 'Zárófödém típusa',
      roofArea: 'Tető alapterülete',
      roofMaterial: 'Tető típusa',
      roofBuiltIn: 'Beépített?',
      roofInsulation: 'Hőszigetelés'
    },
    windows: {
      sectionName: 'Nyílászárók',
      windowsWarning: 'A nyílászárók méreteit és típusait a helyszíni felmérés során pontosítjuk.',
      smallWindow: 'Kisablak (90 cm × 90 cm-nél kisebb)',
      mediumWindow: 'Közepes ablak (90 cm × 90 cm - 150 cm × 150 cm)',
      largeWindow: 'Nagy ablak (150 cm × 150 cm-nél nagyobb)',
      wood: 'Fa',
      plastic: 'Műanyag',
      metal: 'Fém',
      d1: 'd1',
      d2: 'd2',
      d3: 'd3'
    },
    propertyTypes: {
      familyHouse: 'Családi ház',
      semiDetached: 'Ikerház',
      terraced: 'Sorház'
    },
    buildingStoryOptions: {
      oneStory: '1 szintes ház',
      twoStory: '2 szintes ház',
      threeStory: '3 szintes ház',
      moreThanThree: 'Több, mint 3 szintes'
    },
    wallTypes: {
      pleaseSelect: 'Kérjük, válasszon',
      smallSolidBrick: 'Kis méretű tömör tégla',
      limeSandBrick: 'Mészhomok tégla',
      b30Brick: 'B30 tégla',
      poroton: 'Poroton',
      gasSilicate: 'Gázsilikát',
      bautherm: 'Bautherm',
      porothermNF: 'Porotherm N+F',
      ytong: 'Ytong',
      reinforcedConcretePanel: 'Vasbeton panel',
      adobe: 'Vályog',
      lightweightStructure: 'Könnyűszerkezetes'
    },
    roofTypes: {
      tentRoof: 'Sátortető',
      flatRoof: 'Lapostető'
    },
    roofMaterials: {
      tile: 'Cserép',
      slate: 'Pala',
      metal: 'Lemezelt'
    },
    windowGlazingTypes: {
      singleLayer: '1 rétegű üvegezésű',
      doubleLayer: '2 rétegű üvegezésű',
      tripleLayer: '3 rétegű üvegezésű',
      doubleScrewTeschauer: '2 rétegű csavaros teschauer',
      doubleConnectedFrame: '2 rétegű kapcsolt gerébtokos'
    },
    windowOpeningTypes: {
      simple: 'Egyszerű',
      tilt: 'Bukó',
      turn: 'Nyíló',
      tiltTurn: 'Bukó-nyíló',
      sliding: 'Tolóajtó'
    },
    windowShutterTypes: {
      none: 'Nincs',
      external: 'Külső',
      internal: 'Belső',
      both: 'Mindkettő'
    },
    orientations: {
      north: 'É',
      northeast: 'ÉK',
      east: 'K',
      southeast: 'DK',
      south: 'D',
      southwest: 'DNy',
      west: 'Ny',
      northwest: 'ÉNy'
    },
    units: {
      celsius: '°C',
      squareMeters: 'm²',
      centimeters: 'cm',
      meters: 'm',
      percent: '%',
      pieces: 'db'
    },
    placeholders: {
      constructionYear: 'Építési év',
      pieces: 'db'
    }
  },
  heatPumpSurvey: {
    general: {
      sectionName: 'Általános adatok',
      propertyType: 'Ingatlan típusa',
      propertyTypeOther: 'Típus',
      constructionYear: 'A lakás/ház építési éve',
      propertyLocation: 'Ingatlan fekvése',
      monumentProtection: 'Az épület műemlékvédelem alatt áll',
      heatPumpType: 'Hőszivattyú típusa',
      buildingFloors: 'Épület szintjeinek száma, padlástér nélkül',
      floorsExplanation: 'Földszint plusz 1 emelet esetén = 2',
      atticBuiltIn: 'Tetőtér beépített és lakott',
      atticInsulation: 'A padlástér födémje felett, vagy a tetőben van-e hőszigetelés?',
      atticInsulationSize: 'Mérete',
      buildingArea: 'Épület alapterülete (m²)',
      ceilingHeight: 'Belmagasság (m)',
      heatedArea: 'Fűtött alapterület (m²)',
      wetRoomsCount: 'Vizes helyiségek száma',
      wallTypeThickness: 'Falazat típusa és vastagsága',
      thermalInsulation: 'Hőszigetelés',
      thermalInsulationThickness: 'Vastagsága (cm)',
      ceilingInsulation: 'Födém szigetelés',
      ceilingInsulationThickness: 'Födém szigetelés vastagsága (cm)',
      facadeInsulation: 'Homlokzat szigetelés',
      facadeInsulationThickness: 'Homlokzat szigetelés vastagsága (cm)',
      windowDoorType: 'Nyílászárók típusa',
      windowShading: 'Nyílászárók árnyékolása',
      phaseCount: 'Hány fázis áll rendelkezésre?',
      phase1: 'Fázis 1',
      phase2: 'Fázis 2',
      phase3: 'Fázis 3'
    },
    rooms: {
      sectionName: 'Helyiségek',
      roomName: 'Elnevezés',
      roomSize: 'Méret'
    },
    windows: {
      sectionName: 'Nyílászárók',
      windowType: 'Típus',
      windowMaterial: 'Anyag',
      windowGlazing: 'Üvegezés',
      windowQuantity: 'Mennyiség'
    },
    heatingBasics: {
      sectionName: 'Fűtési alapadatok',
      currentHeatingSolution: 'Jelenlegi fűtési megoldás',
      currentHeatingSolutionOther: 'Típus',
      currentHeatDistribution: 'Jelenlegi hőleadó kör',
      currentHeatDistributionOther: 'Típus',
      currentHotWater: 'Jelenlegi HMV',
      currentHotWaterSize: 'Mérete (liter)',
      solarCollectorSupport: 'Napkollektoros rásegítés?'
    },
    radiators: {
      sectionName: 'Radiátorok',
      radiatorSize: 'Méret'
    },
    desiredConstruction: {
      sectionName: 'Tervezett kivitelezés',
      goal: 'Cél',
      subsidy: 'Pályázat?',
      heatPumpUsage: 'Mire szeretné használni a hőszivattyút?',
      hotWaterSolution: 'HMV?',
      externalStorage: 'Külső tároló?',
      heatDistribution: 'Hőleadó',
      hTariff: 'H tarifát szeretne igényelni?',
      tankCapacity: 'Hány literes tartályra van szükség?'
    },
    otherData: {
      sectionName: 'Egyéb adatok',
      annualGasConsumption: 'Elmúlt 1 év gázfogyasztása',
      gasConsumptionNote: 'Számla alapján',
      calculatedHeatDemand: 'Számított hőszükséglet',
      calculationSource: 'Forrása',
      calculationSourceNote: 'Ha van szakember által készített kalkuláció',
      calculatedWinterHeatLoss: 'Számított téli hőveszteség',
      summerHeatLoad: 'Nyári hőterhelés',
      indoorUnitFits: 'Beltéri egység elfér',
      indoorOutdoorDistance: 'Beltéri és kültéri egység közötti távolság (m)',
      outdoorUnitInstallable: 'Kültéri egység kihelyezhető?'
    }
  }
}
