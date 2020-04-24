extends Spatial

# MARKUP - : Properties
const ammoInMag   = 1
const canReload = false
const canRefill = false 
const damage      = 40
const fireAnimationName    = "Knife_fire"
const idleAnimationName    = "Knife_idle"
const reloadingAnimationName  = ""

var ammoInWeapon        = 1
var ammoSpare           = 1
var isWeaponEnabled     = false
var playerNode          = null


# MARKUP - : Ready
func ready() : 
   pass
   
   
# MARKUP - : functions
func fireWeapon() : 
   var area = $Area
   var bodies = area.get_overlapping_bodies()
   
   for body in bodies : 
      if body == playerNode :
         continue
         
      if body.has_method("bulletHit") :
         body.bulletHit(damage, area.global_transform)
      
func equipWeapon() :
   if playerNode.animationManager.currentState == idleAnimationName :
      isWeaponEnabled = true
      return true
      
   if playerNode.animationManager.currentState == "Idle_unarmed" :
      playerNode.animationManager.setAnimation("Knife_equip")
      
   return false
      
func unequipWeapon() : 
   if playerNode.animationManager.currentState == idleAnimationName :
      playerNode.animationManager.setAnimation("Knife_unequip")
      
   if playerNode.animationManager.currentState == "Idle_unarmed" :
      isWeaponEnabled = false
      return true
   
   return false
   
func reloadWeapon() :
   return false 

