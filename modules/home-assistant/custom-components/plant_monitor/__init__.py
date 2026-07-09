"""Plant Monitor - configurable plant humidity monitoring."""
import logging
from datetime import datetime, timedelta

from homeassistant.components.sensor import SensorEntity
from homeassistant.const import CONF_NAME, STATE_UNKNOWN
from homeassistant.core import HomeAssistant
from homeassistant.helpers.entity_platform import AddEntitiesCallback
from homeassistant.helpers.typing import ConfigType, DiscoveryInfoType
from homeassistant.util import dt as dt_util
import voluptuous as vol
import homeassistant.helpers.config_validation as cv

_LOGGER = logging.getLogger(__name__)

DOMAIN = "plant_monitor"
CONF_PLANTS = "plants"
CONF_SENSOR = "sensor"
CONF_MIN_HUMIDITY = "min_humidity"
CONF_MAX_HUMIDITY = "max_humidity"
CONF_MAX_TIME_ABOVE = "max_time_above"
CONF_MAX_TIME_BELOW = "max_time_below"

PLANT_SCHEMA = vol.Schema(
    {
        vol.Required(CONF_NAME): cv.string,
        vol.Required(CONF_SENSOR): cv.entity_id,
        vol.Optional(CONF_MIN_HUMIDITY, default=40): vol.Coerce(float),
        vol.Optional(CONF_MAX_HUMIDITY, default=80): vol.Coerce(float),
        vol.Optional(CONF_MAX_TIME_ABOVE, default=48): vol.Coerce(int),
        vol.Optional(CONF_MAX_TIME_BELOW, default=4): vol.Coerce(int),
    }
)

CONFIG_SCHEMA = vol.Schema(
    {
        DOMAIN: vol.Schema(
            {
                vol.Required(CONF_PLANTS): vol.Schema(
                    {cv.string: PLANT_SCHEMA}
                ),
            }
        )
    },
    extra=vol.ALLOW_EXTRA,
)


async def async_setup(hass: HomeAssistant, config: dict) -> bool:
    """Set up the Plant Monitor component."""
    if DOMAIN not in config:
        return True

    hass.data.setdefault(DOMAIN, {})
    plants = config[DOMAIN][CONF_PLANTS]

    for plant_id, plant_config in plants.items():
        hass.data[DOMAIN][plant_id] = plant_config

    return True


class PlantStatusSensor(SensorEntity):
    """Sensor showing plant status with humidity and temperature."""

    def __init__(self, hass: HomeAssistant, plant_id: str, config: dict):
        """Initialize the sensor."""
        super().__init__()
        self._hass = hass
        self._plant_id = plant_id
        self._config = config
        self._attr_name = config[CONF_NAME]
        self._attr_unique_id = f"plant_monitor_{plant_id}_status"
        self._attr_icon = "mdi:flower"
        self._attr_native_value = None
        self._attr_extra_state_attributes = {}

    def _get_humidity(self) -> float | None:
        """Get current humidity from the source sensor."""
        sensor_id = self._config[CONF_SENSOR]
        state = self._hass.states.get(sensor_id)
        if state is None:
            return None
        if state.state in (STATE_UNKNOWN, "unavailable", "unknown"):
            return None
        try:
            return float(state.state)
        except (ValueError, TypeError):
            return None

    def _get_temperature(self) -> float | None:
        """Get temperature from the plant sensor."""
        sensor_id = self._config[CONF_SENSOR]
        temp_sensor = sensor_id.replace("_humidity", "_temperature")
        state = self._hass.states.get(temp_sensor)
        if state is None:
            return None
        if state.state in (STATE_UNKNOWN, "unavailable", "unknown"):
            return None
        try:
            return float(state.state)
        except (ValueError, TypeError):
            return None

    def _get_threshold(self, key: str) -> float:
        """Get threshold value from input_number helper."""
        helper_id = f"input_number.plant_{self._plant_id}_{key}"
        state = self._hass.states.get(helper_id)
        if state and state.state != STATE_UNKNOWN:
            try:
                return float(state.state)
            except (ValueError, TypeError):
                pass
        return self._config.get(key, 40)

    def _get_last_event_time(self, key: str) -> datetime | None:
        """Get last event time from input_datetime helper."""
        helper_id = f"input_datetime.plant_{self._plant_id}_{key}"
        state = self._hass.states.get(helper_id)
        if state and state.state != STATE_UNKNOWN:
            try:
                return dt_util.parse_datetime(state.state)
            except (ValueError, TypeError):
                pass
        return None

    def _set_last_event_time(self, key: str, when: datetime | None):
        """Set last event time in input_datetime helper."""
        helper_id = f"input_datetime.plant_{self._plant_id}_{key}"
        if when is None:
            self._hass.states.async_set(helper_id, "unknown")
        else:
            self._hass.states.async_set(helper_id, when.isoformat())

    def _get_status(self) -> tuple[str, str]:
        """Get plant status and icon."""
        humidity = self._get_humidity()

        # Handle missing/unavailable sensor
        if humidity is None:
            return "Offline", "mdi:help-circle"

        min_h = self._get_threshold(CONF_MIN_HUMIDITY)
        max_h = self._get_threshold(CONF_MAX_HUMIDITY)
        max_time_above = self._get_threshold(CONF_MAX_TIME_ABOVE)
        max_time_below = self._get_threshold(CONF_MAX_TIME_BELOW)

        now = dt_util.utcnow()

        # Immediate red: > max + 5% or < min - 5%
        if humidity > max_h + 5:
            return f"{humidity:.0f}% ⚠", "mdi:alert-circle"
        if humidity < min_h - 5:
            return f"{humidity:.0f}% ⚠", "mdi:alert-circle"

        if humidity > max_h:
            last_above = self._get_last_event_time("last_above_max")
            if last_above is None:
                self._set_last_event_time("last_above_max", now)
                last_above = now
            hours_above = (now - last_above).total_seconds() / 3600
            if hours_above > max_time_above:
                return f"{humidity:.0f}% ⚠", "mdi:alert-circle"
            return f"{humidity:.0f}% ▲", "mdi:arrow-up-bold"

        if humidity < min_h:
            last_below = self._get_last_event_time("last_below_min")
            if last_below is None:
                self._set_last_event_time("last_below_min", now)
                last_below = now
            hours_below = (now - last_below).total_seconds() / 3600
            if hours_below > max_time_below:
                return f"{humidity:.0f}% ⚠", "mdi:alert-circle"
            return f"{humidity:.0f}% ▼", "mdi:arrow-down-bold"

        # Within range - reset timers
        self._set_last_event_time("last_above_max", None)
        self._set_last_event_time("last_below_min", None)

        temperature = self._get_temperature()
        return f"{humidity:.0f}% · {temperature:.0f}°C", "mdi:flower"

    async def async_update(self):
        """Update the sensor."""
        status, icon = self._get_status()
        self._attr_native_value = status
        self._attr_icon = icon
        self._attr_extra_state_attributes = {
            "humidity": self._get_humidity(),
            "temperature": self._get_temperature(),
            "min_humidity": self._get_threshold(CONF_MIN_HUMIDITY),
            "max_humidity": self._get_threshold(CONF_MAX_HUMIDITY),
            "sensor_entity": self._config[CONF_SENSOR],
        }


class PlantColorSensor(SensorEntity):
    """Sensor showing plant color for conditional cards."""

    def __init__(self, hass: HomeAssistant, plant_id: str, config: dict):
        """Initialize the sensor."""
        super().__init__()
        self._hass = hass
        self._plant_id = plant_id
        self._config = config
        self._attr_name = f"{config[CONF_NAME]} color"
        self._attr_unique_id = f"plant_monitor_{plant_id}_color"
        self._attr_icon = "mdi:palette"
        self._attr_native_value = "green"

    def _get_humidity(self) -> float | None:
        """Get current humidity from the source sensor."""
        sensor_id = self._config[CONF_SENSOR]
        state = self._hass.states.get(sensor_id)
        if state is None:
            return None
        if state.state in (STATE_UNKNOWN, "unavailable", "unknown"):
            return None
        try:
            return float(state.state)
        except (ValueError, TypeError):
            return None

    def _get_threshold(self, key: str) -> float:
        """Get threshold value from input_number helper."""
        helper_id = f"input_number.plant_{self._plant_id}_{key}"
        state = self._hass.states.get(helper_id)
        if state and state.state != STATE_UNKNOWN:
            try:
                return float(state.state)
            except (ValueError, TypeError):
                pass
        return self._config.get(key, 40)

    def _get_last_event_time(self, key: str) -> datetime | None:
        """Get last event time from input_datetime helper."""
        helper_id = f"input_datetime.plant_{self._plant_id}_{key}"
        state = self._hass.states.get(helper_id)
        if state and state.state != STATE_UNKNOWN:
            try:
                return dt_util.parse_datetime(state.state)
            except (ValueError, TypeError):
                pass
        return None

    def _get_color(self) -> str:
        """Get plant color based on status."""
        humidity = self._get_humidity()

        # Handle missing/unavailable sensor
        if humidity is None:
            return "gray"

        min_h = self._get_threshold(CONF_MIN_HUMIDITY)
        max_h = self._get_threshold(CONF_MAX_HUMIDITY)
        max_time_above = self._get_threshold(CONF_MAX_TIME_ABOVE)
        max_time_below = self._get_threshold(CONF_MAX_TIME_BELOW)

        now = dt_util.utcnow()

        # Immediate red conditions
        if humidity > max_h + 5 or humidity < min_h - 5:
            return "red"

        if humidity > max_h:
            last_above = self._get_last_event_time("last_above_max")
            if last_above is None:
                return "orange"
            hours_above = (now - last_above).total_seconds() / 3600
            return "red" if hours_above > max_time_above else "orange"

        if humidity < min_h:
            last_below = self._get_last_event_time("last_below_min")
            if last_below is None:
                return "orange"
            hours_below = (now - last_below).total_seconds() / 3600
            return "red" if hours_below > max_time_below else "orange"

        return "green"

    async def async_update(self):
        """Update the sensor."""
        self._attr_native_value = self._get_color()


class PlantOverallStatusSensor(SensorEntity):
    """Sensor showing overall plant status across all plants."""

    def __init__(self, hass: HomeAssistant):
        """Initialize the sensor."""
        super().__init__()
        self._hass = hass
        self._attr_name = "Piante"
        self._attr_unique_id = "plant_monitor_overall_status"
        self._attr_icon = "mdi:flower"
        self._attr_native_value = "loading"
        self._attr_extra_state_attributes = {}

    def _get_color(self) -> str:
        """Get worst color across all plants."""
        if DOMAIN not in self._hass.data:
            return "gray"

        priority = {"red": 3, "orange": 2, "green": 1, "gray": 0}
        worst = "gray"
        worst_priority = 0
        plant_colors = {}

        for plant_id in self._hass.data[DOMAIN]:
            color_sensor_id = f"sensor.{plant_id}_color"
            state = self._hass.states.get(color_sensor_id)
            if state and state.state in priority:
                color = state.state
                plant_colors[plant_id] = color
                if priority[color] > worst_priority:
                    worst = color
                    worst_priority = priority[color]

        self._attr_extra_state_attributes = {"plants": plant_colors}
        return worst

    async def async_update(self):
        """Update the sensor."""
        self._attr_native_value = self._get_color()


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

    async_add_entities(entities)
