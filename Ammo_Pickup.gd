extends Spatial

# MARKUP - : Properties
export (int, "full size", "small") var kitSize = 0 setget kitSizeChange

# 0 = full size pickup, 1 = small pickup
const ammoAmounts = [4, 1]

const respawnTime = 20
var respawnTimer = 0

var isReady = 0 


# MARKUP - : Ready
func _ready():
# warning-ignore:return_value_discarded
   $Holder/Ammo_Pickup_Trigger.connect("body_entered", self, "triggerBodyEntered")
   isReady = true 
   
   kitSizeChangeValues(0, false)
   kitSizeChangeValues(1, false)
   kitSizeChangeValues(kitSize, true)
 
  
# MARKUP - : Functions
func _physics_process(delta) :
   if respawnTimer > 0 :
      respawnTimer -= delta
      
      if respawnTimer <= 0 :
         kitSizeChangeValues(kitSize, true)

func kitSizeChange(value) :
   if isReady :
      kitSizeChangeValues(kitSize, false)
      kitSize = value
      kitSizeChangeValues(kitSize, true)
   else :
      kitSize = value
      
func kitSizeChangeValues(size, enable) :
   if size == 0 :
      $Holder/Ammo_Pickup_Trigger/Shape_Kit.disabled = !enable
      $Holder/Ammo_Kit.visible = enable
   elif size == 1 :
      $Holder/Ammo_Pickup_Trigger/Shape_Kit_Small.disabled = !enable
      $Holder/Ammo_Kit_Small.visible = enable
   
func triggerBodyEntered(body) :
   if body.has_method("addAmmo") :
      body.addAmmo(ammoAmounts[kitSize])
      respawnTimer = respawnTime
      kitSizeChangeValues(kitSize, false)

   

   
   
   
