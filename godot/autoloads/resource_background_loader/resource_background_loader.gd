class_name ResourceBackgroundLoader
extends Node

var resource_uid_to_token_array_dict: Dictionary[StringName, ResourceBackgroundLoaderTokenArray] = {}
var resource_uid_to_resource_dict: Dictionary[StringName, Resource] = {}

var non_loaded_tokens: Array[ResourceBackgroundLoaderToken] = []

func _enter_tree() -> void:
	Global.resource_background_loader = self

func _process(delta: float) -> void:
	# Mark any tokens with loaded resources.
	var new_non_loaded_tokens: Array[ResourceBackgroundLoaderToken] = []
	for token: ResourceBackgroundLoaderToken in non_loaded_tokens:
		var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(token.resource_uid)
		match status:
			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
				var _resource: Resource = _get_and_cache_resource(token)
				token.is_loaded = true
			_:
				new_non_loaded_tokens.append(token)
	if new_non_loaded_tokens.size() != non_loaded_tokens.size():
		non_loaded_tokens.assign(new_non_loaded_tokens)

func cache_resource(resource_uid: StringName) -> ResourceBackgroundLoaderToken:
	var result: Error = ResourceLoader.load_threaded_request(resource_uid)
	if result != Error.OK:
		printerr("Error in cache_resource(): %s" % result)
	
	var token: ResourceBackgroundLoaderToken = ResourceBackgroundLoaderToken.new()
	token.resource_uid = resource_uid
	
	var token_array: ResourceBackgroundLoaderTokenArray = resource_uid_to_token_array_dict.get_or_add(resource_uid, ResourceBackgroundLoaderTokenArray.new())
	token_array.tokens.append(token)

	non_loaded_tokens.append(token)
	
	return token

func uncache_resource(token: ResourceBackgroundLoaderToken) -> void:
	if resource_uid_to_token_array_dict.has(token.resource_uid):
		# Stop tracking this token for the resource.
		var token_array: ResourceBackgroundLoaderTokenArray = resource_uid_to_token_array_dict.get(token.resource_uid)
		var token_index: int = token_array.tokens.find(token)
		if token_index != -1:
			token_array.tokens.remove_at(token_index)
		
		# If not loaded, stop checking it.
		if non_loaded_tokens.has(token):
			non_loaded_tokens.erase(token)
		
		# If no tokens for this resource remain, uncache it.
		if token_array.tokens.size() == 0:
			resource_uid_to_token_array_dict.erase(token.resource_uid)
			resource_uid_to_resource_dict.erase(token.resource_uid)
			print("ResourceBackgroundLoader: Uncaching resource %s." % token.resource_uid)

func get_resource(token: ResourceBackgroundLoaderToken) -> Resource:
	var resource: Resource = _get_and_cache_resource(token)
	return resource

func _get_and_cache_resource(token: ResourceBackgroundLoaderToken) -> Resource:
	var resource: Resource = null
	# If cached, get it.
	if resource_uid_to_resource_dict.has(token.resource_uid):
		resource = resource_uid_to_resource_dict.get(token.resource_uid)
	# If not cached, cache it.
	else:
		resource = ResourceLoader.load_threaded_get(token.resource_uid)
		if resource == null:
			printerr("ResourceBackgroundLoader: resource %s is null?" % token.resource_uid)
			return
		resource_uid_to_resource_dict.set(token.resource_uid, resource)
		print("ResourceBackgroundLoader: Caching resource %s." % token.resource_uid)
	return resource
