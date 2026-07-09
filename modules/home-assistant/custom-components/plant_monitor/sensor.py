"""Plant Monitor sensor platform."""
from homeassistant.core import HomeAssistant
from homeassistant.helpers.entity_platform import AddEntitiesCallback
from homeassistant.helpers.typing import ConfigType, DiscoveryInfoType

from . import DOMAIN, PlantStatusSensor, PlantColorSensor


async def async_setup_platform(
    hass: HomeAssistant,
    config: ConfigType,
    async_add_entities: AddEntitiesCallback,
    discovery_info: DiscoveryInfoType | None = None,
) -> None:
    """Set up the sensor platform."""
    if DOMAIN not in hass.data:
        return

    entities = []
    for plant_id, plant_config in hass.data[DOMAIN].items():
        entities.append(PlantStatusSensor(hass, plant_id, plant_config))
        entities.append(PlantColorSensor(hass, plant_id, plant_config))

    async_add_entities(entities, update_before_add=True)
