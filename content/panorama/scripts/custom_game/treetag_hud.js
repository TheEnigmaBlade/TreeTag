function UpdatePlayerWood(msg) {
	var $wood = $("#Wood");
	var $value = $wood.GetChild(1);
	
	var newValue = msg.wood;
	$value.text = newValue.toString();
}

(function() {
	GameEvents.Subscribe("player_has_wood", UpdatePlayerWood);
})();
