extends Control

signal moving_container_pressed
signal moving_container_held
signal moving_container_released

const HOLD_THRESHOLD : float = 0.3

var is_holding : bool = false
