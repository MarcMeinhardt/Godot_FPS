extends Spatial

# MARKUP - : Properties
export (int, "full size", "small") var kitSize = 0 setget kitSizeChange
# GDSCRIPT : setget functions
# it is often useful to know when a class’ member variable changes for whatever reason
# it may also be desired to encapsulate its access in some way

const healthAmounts = [70, 30]
# 0 = full size pickup, 1 = small pickup

var respawnTime = 20
var respawnTimer = 0
var isReady = false
# isReady used as setget functions are called before _ready()

# MARKUP - : Ready
func _ready(): 
   $Holder/Health_Pickup_Trigger.connect("body_entered", self, "triggerBodyEntered")

   isReady = true
   
   kitSizeChangeValues(0, false)
   kitSizeChangeValues(1, false)
   kitSizeChangeValues(kitSize, true)
   # (size of the kit, disable or enable the collision shape and mesh for size)
   

# MARKUP - : Function
func _physics_process(delta):
   if respawnTime > 0 : 
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
      $Holder/Health_Pickup_Trigger/Shape_Kit.disabled = !enable
      $Holder/Health_Kit.visible = enable
      # get the collision shape for the size 0 and disable it 
      # = !enable is used to enable it ("not" enable disabled)
      # get the spatial holding the mesh and make it visible
   elif size == 1 :
      $Holder/Health_Pickup_Trigger/Shape_Kit_Small.disabled = !enable
      $Holder/Health_Kit_Small.visible = enable
      

func triggerBodyEntered(body) :
   if body.has_method("addHealth") :
      body.addHealth(healthAmounts[kitSize])
      respawnTimer = respawnTime
      kitSizeChangeValues(kitSize, false)
      
      
      
