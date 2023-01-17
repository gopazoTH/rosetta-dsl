package com.regnosys.rosetta.validation

import com.regnosys.rosetta.rosetta.RosettaType

class BindableType {
		public RosettaType type
		public String genericName

		def isBound() {
			type !== null || genericName !== null
		}

		def setGenericName(String genericName) {
			type = null
			this.genericName = genericName
		}
	}