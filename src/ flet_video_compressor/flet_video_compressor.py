from typing import Any, Optional, Callable
from flet.core.constrained_control import ConstrainedControl
from flet.core.control import OptionalNumber


class FletVideoCompressor(ConstrainedControl):
    """
    Python wrapper for the custom FletVideoCompressor Flutter control.
    """

    def __init__(
        self,
        source_path: Optional[str] = None,
        destination_path: Optional[str] = None,
        on_compressed: Optional[Callable] = None,
        #
        # Control props
        #
        opacity: OptionalNumber = None,
        tooltip: Optional[str] = None,
        visible: Optional[bool] = None,
        data: Any = None,
        #
        # ConstrainedControl props
        #
        left: OptionalNumber = None,
        top: OptionalNumber = None,
        right: OptionalNumber = None,
        bottom: OptionalNumber = None,
    ):
        super().__init__(
            tooltip=tooltip,
            opacity=opacity,
            visible=visible,
            data=data,
            left=left,
            top=top,
            right=right,
            bottom=bottom,
        )

        self.source_path = source_path
        self.destination_path = destination_path
        self.on_compressed = on_compressed

    def _get_control_name(self):
        return "flet_video_compressor"

    # source_path
    @property
    def source_path(self):
        return self._get_attr("sourcePath")

    @source_path.setter
    def source_path(self, value):
        self._set_attr("sourcePath", value)

    # destination_path
    @property
    def destination_path(self):
        return self._get_attr("destinationPath")

    @destination_path.setter
    def destination_path(self, value):
        self._set_attr("destinationPath", value)

    # Bind the Dart "onCompressed" event to Python
    def _before_build_command(self):
        if self.on_compressed:
            self._add_event_handler("onCompressed", self.on_compressed)
