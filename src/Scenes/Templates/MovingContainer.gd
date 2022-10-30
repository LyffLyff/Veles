extends Control

#SIGNALS
signal MovingContainerPressed
signal HoldingMovableContainer
signal ReleasedMovableContainer

#CONSTANTS
const HoldThreshold : float = 0.3

#VARIABLES
var Holding : bool = false
