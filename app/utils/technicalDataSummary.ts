/**
 * Calculate technical data summary for display in investment headers
 */
export function getTechnicalDataSummary(investmentType: string, packageData: any): string {
  if (!packageData) return ''

  switch (investmentType) {
    case 'solarPanel':
      return getSolarPanelSummary(packageData)

    case 'solarPanelBattery':
      return getSolarPanelBatterySummary(packageData)

    case 'heatPump':
      return getHeatPumpSummary(packageData)

    case 'battery':
      return getBatterySummary(packageData)

    case 'facadeInsulation':
    case 'roofInsulation':
      return getInsulationSummary(packageData)

    case 'windows':
      return getWindowsSummary(packageData)

    case 'airConditioner':
      return getAirConditionerSummary(packageData)

    case 'carCharger':
      return getCarChargerSummary(packageData)
  }

  return ''
}

function getSolarPanelSummary(packageData: any): string {
  let totalPanelPower = 0
  let inverterPower = 0

  if (packageData.panel && Array.isArray(packageData.panel)) {
    packageData.panel.forEach((item: any) => {
      if (item.product && item.quantity) {
        const power = item.product.power || 0
        const quantity = parseInt(item.quantity) || 0
        totalPanelPower += power * quantity
      }
    })
  }

  if (packageData.inverter && Array.isArray(packageData.inverter) && packageData.inverter.length > 0) {
    const inverter = packageData.inverter[0]
    if (inverter.product && inverter.product.power) {
      inverterPower = inverter.product.power / 1000
    }
  }

  if (totalPanelPower > 0 || inverterPower > 0) {
    const dcPower = totalPanelPower > 0 ? (totalPanelPower / 1000).toFixed(1) : '0.0'
    const acPower = inverterPower > 0 ? inverterPower.toFixed(1) : '0.0'
    return `DC: ${dcPower} kW, AC: ${acPower} kW`
  }

  return ''
}

function getSolarPanelBatterySummary(packageData: any): string {
  let totalPanelPower = 0
  let inverterPower = 0
  let batteryCapacity = 0

  if (packageData.panel && Array.isArray(packageData.panel)) {
    packageData.panel.forEach((item: any) => {
      if (item.product && item.quantity) {
        const power = item.product.power || 0
        const quantity = parseInt(item.quantity) || 0
        totalPanelPower += power * quantity
      }
    })
  }

  if (packageData.inverter && Array.isArray(packageData.inverter) && packageData.inverter.length > 0) {
    const inverter = packageData.inverter[0]
    if (inverter.product && inverter.product.power) {
      inverterPower = inverter.product.power / 1000
    }
  }

  if (packageData.battery && Array.isArray(packageData.battery) && packageData.battery.length > 0) {
    const battery = packageData.battery[0]
    if (battery.product && battery.product.capacity) {
      batteryCapacity = battery.product.capacity
      const quantity = parseInt(battery.quantity) || 1
      batteryCapacity *= quantity
    }
  }

  if (totalPanelPower > 0 || inverterPower > 0 || batteryCapacity > 0) {
    const dcPower = totalPanelPower > 0 ? (totalPanelPower / 1000).toFixed(1) : '0.0'
    const acPower = inverterPower > 0 ? inverterPower.toFixed(1) : '0.0'
    const batterySummary = batteryCapacity > 0 ? `, B: ${batteryCapacity.toFixed(1)} kWh` : ''
    return `DC: ${dcPower} kW, AC: ${acPower} kW${batterySummary}`
  }

  return ''
}

function getHeatPumpSummary(packageData: any): string {
  let heatPumpPower = 0
  let heatPumpCOP = 0
  let accessoryVolume = 0

  if (packageData.heatpump && Array.isArray(packageData.heatpump) && packageData.heatpump.length > 0) {
    const heatPump = packageData.heatpump[0]
    if (heatPump.product && heatPump.product.power) {
      heatPumpPower = heatPump.product.power
      const quantity = parseInt(heatPump.quantity) || 1
      heatPumpPower *= quantity
    }

    if (heatPump.product && heatPump.product.cop) {
      heatPumpCOP = heatPump.product.cop
    }
  }

  // Get accessory data (e.g., water tank volume)
  if (packageData.accessory && Array.isArray(packageData.accessory) && packageData.accessory.length > 0) {
    packageData.accessory.forEach((item: any) => {
      if (item.product && item.product.volume && item.quantity) {
        const volume = item.product.volume || 0
        const quantity = parseInt(item.quantity) || 1
        accessoryVolume += volume * quantity
      }
    })
  }

  const parts: string[] = []
  if (heatPumpPower > 0) {
    // Convert to appropriate power unit
    if (heatPumpPower >= 1000) {
      parts.push(`${(heatPumpPower / 1000).toFixed(1)} kW`)
    } else {
      parts.push(`${heatPumpPower.toFixed(1)} W`)
    }
  }
  if (accessoryVolume > 0) {
    parts.push(`${accessoryVolume} l`)
  }
  if (heatPumpCOP > 0) {
    parts.push(`COP: ${heatPumpCOP.toFixed(1)}`)
  }

  return parts.join(', ')
}

function getBatterySummary(packageData: any): string {
  let batteryCapacity = 0
  let batteryCount = 0

  if (packageData.battery && Array.isArray(packageData.battery)) {
    packageData.battery.forEach((item: any) => {
      if (item.product && item.quantity) {
        const capacity = item.product.capacity || 0
        const quantity = parseInt(item.quantity) || 0
        batteryCapacity += capacity * quantity
        batteryCount += quantity
      }
    })
  }

  if (batteryCapacity > 0) {
    let summary = `${batteryCapacity.toFixed(1)} kWh`
    if (batteryCount > 1) {
      summary += `, ${batteryCount} db`
    }
    return summary
  }

  return ''
}

function getInsulationSummary(packageData: any): string {
  let insulationThickness = 0
  let insulationArea = 0

  if (packageData.insulation && Array.isArray(packageData.insulation) && packageData.insulation.length > 0) {
    packageData.insulation.forEach((item: any) => {
      if (item.product && item.product.thickness && item.quantity) {
        // Use the thickness of the first insulation product with a thickness value
        if (insulationThickness === 0) {
          insulationThickness = item.product.thickness
        }
      }
    })
  }

  if (packageData.area) {
    insulationArea = packageData.area
  }

  if (insulationThickness > 0) {
    let summary = `${insulationThickness} cm`
    if (insulationArea > 0) {
      summary += `, ${insulationArea} m²`
    }
    return summary
  }

  return ''
}

function getWindowsSummary(packageData: any): string {
  let windowCount = 0
  let uValue = 0

  if (packageData.window && Array.isArray(packageData.window)) {
    packageData.window.forEach((item: any) => {
      if (item.product && item.quantity) {
        const quantity = parseInt(item.quantity) || 0
        windowCount += quantity

        if (uValue === 0 && item.product.uValue) {
          uValue = item.product.uValue
        }
      }
    })
  }

  if (windowCount > 0) {
    let summary = `${windowCount} db`
    if (uValue > 0) {
      summary += `, U=${uValue.toFixed(2)} W/m²K`
    }
    return summary
  }

  return ''
}

function getAirConditionerSummary(packageData: any): string {
  let acPower = 0
  let acCount = 0
  let energyClass = ''
  let efficiency = 0

  if (packageData.airconditioner && Array.isArray(packageData.airconditioner)) {
    packageData.airconditioner.forEach((item: any) => {
      if (item.product && item.quantity) {
        const power = item.product.power || 0
        const quantity = parseInt(item.quantity) || 0
        acPower += power * quantity
        acCount += quantity

        if (!energyClass && item.product.energyClass) {
          energyClass = item.product.energyClass
        }

        if (efficiency === 0 && item.product.efficiency) {
          efficiency = item.product.efficiency
        }
      }
    })
  }

  if (acPower > 0 || acCount > 0) {
    const parts: string[] = []
    if (acPower > 0) {
      // Convert to appropriate power unit
      if (acPower >= 1000) {
        parts.push(`${(acPower / 1000).toFixed(1)} kW`)
      } else {
        parts.push(`${acPower.toFixed(1)} W`)
      }
    }
    if (energyClass) {
      parts.push(energyClass)
    }
    if (efficiency > 0) {
      parts.push(`SEER: ${efficiency.toFixed(1)}`)
    }
    if (acCount > 1) {
      parts.push(`${acCount} db`)
    }
    return parts.join(', ')
  }

  return ''
}

function getCarChargerSummary(packageData: any): string {
  let chargerPower = 0
  let chargerCount = 0

  if (packageData.charger && Array.isArray(packageData.charger)) {
    packageData.charger.forEach((item: any) => {
      if (item.product && item.quantity) {
        const power = item.product.power || 0
        const quantity = parseInt(item.quantity) || 0
        chargerPower += power * quantity
        chargerCount += quantity
      }
    })
  }

  if (chargerPower > 0 || chargerCount > 0) {
    const parts: string[] = []
    if (chargerPower > 0) {
      // Convert to kW if power is in watts
      if (chargerPower >= 1000) {
        parts.push(`${(chargerPower / 1000).toFixed(0)}kW`)
      } else {
        parts.push(`${chargerPower}W`)
      }
    }
    if (chargerCount > 1) {
      parts.push(`${chargerCount} db`)
    }
    return parts.join(', ')
  }

  return ''
}
