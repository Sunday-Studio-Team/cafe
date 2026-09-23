@tool
class_name CompositorEffectController
extends CompositorEffect

var rendering_device: RenderingDevice

var cached_uniform_set: RID
var cached_texture_rid: RID

var compute_pipeline: RID

@export var compositor_effects: Array[BaseCompositorEffectDefinition]

'''
So main idea is:
	- we inherit from the base class to make callable, small implementations of effects that have their own specific logic

	- we have implementation functions like this file that simply call those inherited objects so that they can do their own custom effect processing logic.
		pros: easily debuggable and reviewable
		cons: not as easy to understand or implement compared to node based or duck typed composition. Plus, the node based version might be slightly more efficient since it utilizes C++ internals

'''

func _init() -> void:
	for ObjectCompositorEffect in compositor_effects:
		@warning_ignore("int_as_enum_without_cast") # fixing this adds needless overhead for the VM, as it can't optimize it
		effect_callback_type |= ObjectCompositorEffect.SetAndReturnEffectCallbackStage()
		ObjectCompositorEffect.Initialize()
		ObjectCompositorEffect.LoadShader(rendering_device)

func _render_callback(ParameterEffectCallbackType: int, ParameterRenderData: RenderData) -> void:
	if(ParameterEffectCallbackType != effect_callback_type || !rendering_device || !compute_pipeline.is_valid()):
		return

	var render_scene_buffers: RenderSceneBuffersRD = ParameterRenderData.get_render_scene_buffers()
	if !render_scene_buffers:
		print("Unable to get render scene buffers.")
		return

	var render_scene_buffers_size := render_scene_buffers.get_internal_size()
	if(render_scene_buffers_size.x == 0 || render_scene_buffers_size.y == 0):
		return

	var target_render_image := render_scene_buffers.get_color_layer(0)

	# define uniform creation
	for ObjectCompositorEffect in compositor_effects:
		if !(ParameterEffectCallbackType && ObjectCompositorEffect.EffectCallbackStage):
			return

		ObjectCompositorEffect.CreateAndCacheRIDIfChanged(target_render_image, rendering_device)

	var compute_list := rendering_device.compute_list_begin()
	rendering_device.compute_list_bind_compute_pipeline(compute_list, compute_pipeline)
	#execute the effects
	for ObjectCompositorEffect in compositor_effects:
		# GDScript doesn't have proper inlining, so we have to duplicate it
		if !(ParameterEffectCallbackType && ObjectCompositorEffect.EffectCallbackStage):
			return

		ObjectCompositorEffect.DispatchWarp(compute_list, rendering_device, render_scene_buffers_size)

	rendering_device.compute_list_end()
