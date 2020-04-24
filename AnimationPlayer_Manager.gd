extends AnimationPlayer

# MARKUP - : Properties

# STRUCTURE -> Animation_name: [Connecting Animation States]
# Dictionnary for animation states connections
# dictionaryName = { "key" : ["value",] }
var states = {
   "Idle_unarmed" :     ["Knife_equip", "Pistol_equip", "Rifle_equip", "Idle_unarmed"],
   "Pistol_equip" :     ["Pistol_idle"],
   "Pistol_fire" :      ["Pistol_idle"],
   "Pistol_idle" :      ["Pistol_fire", "Pistol_reload", "Pistol_unequip", "Pistol_idle"],
   "Pistol_reload" :    ["Pistol_idle"],
   "Pistol_unequip" :   ["Idle_unarmed"],

   "Rifle_equip" :      ["Rifle_idle"],
   "Rifle_fire" :       ["Rifle_idle"],
   "Rifle_idle" :       ["Rifle_fire", "Rifle_reload", "Rifle_unequip", "Rifle_idle"],
   "Rifle_reload" :     ["Rifle_idle"],
   "Rifle_unequip" :    ["Idle_unarmed"],

   "Knife_equip" :      ["Knife_idle"],
   "Knife_fire" :       ["Knife_idle"],
   "Knife_idle" :       ["Knife_fire", "Knife_unequip", "Knife_idle"],
   "Knife_unequip" :    ["Idle_unarmed"],
  }

# Dictionnary for animation speeds
var animationSpeeds = {
   "Idle_unarmed" :     1,
   
   "Pistol_equip" :     4,
   "Pistol_fire" :      3,
   "Pistol_idle" :      1,
   "Pistol_reload" :    3,
   "Pistol_unequip" :   4,

   "Rifle_equip" :      4,
   "Rifle_fire" :       8,
   "Rifle_idle" :       1,
   "Rifle_reload" :     3,
   "Rifle_unequip" :    4,

   "Knife_equip" :      4,
   "Knife_fire" :       4,
   "Knife_idle" :       0.001,
   "Knife_unequip" :    4,
  }

var currentState     = null
var callBackFunction = null


# MARKUP - : Ready

func _ready():
   setAnimation("Idle_unarmed")
# warning-ignore:return_value_discarded
   connect("animation_finished", self, "animationEnded")
   
# MARKUP - : Functions

func setAnimation(animationName):
   if animationName == currentState: 
      print("AnimationPlayer_Manager.gd -- WARNING: animation is already", animationName)
      return true 
   
   if has_animation(animationName):
      if currentState != null:
         var possibleAnimations = states[currentState]
         if animationName in possibleAnimations:
            currentState = animationName 
            play(animationName, -1, animationSpeeds[animationName])
            return true 
         else:
            print ("AnimationPlayer_Manager.gd -- WARNING: Cannot change to ", animationName, " from ", currentState)
            return false
      else:
            currentState = animationName
            play(animationName, -1, animationSpeeds[animationName])
            return true
   return false
   
# warning-ignore:unused_argument
func animationEnded(animationName):
   
   # ANIMATION : Transitions
   
   # Unarmed
   if currentState == "Idle_unarmed":
      pass 
   # Knife 
   elif currentState == "Knife_equip":
      setAnimation("Knife_idle")
   elif currentState == "Knife_idle":
      pass
   elif currentState == "Knife_fire":
      setAnimation("Knife_idle")
   elif currentState == "Knife_unequip":
      setAnimation("Idle_unarmed")
   # Pistol
   elif currentState == "Pistol_equip":
      setAnimation("Pistol_idle")
   elif currentState == "Pistol_idle":
      pass
   elif currentState == "Pistol_fire":
      setAnimation("Pistol_idle")
   elif currentState == "Pistol_unequip":
      setAnimation("Idle_unarmed")
   elif currentState == "Pistol_reload":
      setAnimation("Pistol_idle")
   # RIFLE transitions
   elif currentState == "Rifle_equip":
      setAnimation("Rifle_idle")
   elif currentState == "Rifle_idle":
      pass;
   elif currentState == "Rifle_fire":
      setAnimation("Rifle_idle")
   elif currentState == "Rifle_unequip":
      setAnimation("Idle_unarmed")
   elif currentState == "Rifle_reload":
      setAnimation("Rifle_idle")
   
func animationCallback():
   if callBackFunction == null :
      print("AnimationPlayer_Manager.gd -- WARNING: No callback function for the animation to call!")
   else:
      callBackFunction.call_func()
   
   
   

