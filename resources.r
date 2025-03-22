#include "Types.r"
#include "SysTypes.r"

resource 'DITL' (128) {
	{	/* array DITLarray: 2 elements */
		/* [1] */
		{109, 252, 129, 310},
		Button {
			enabled,
			"OK"
		};
		/* [2] */
		{9, 9, 61, 312},
		StaticText {
			disabled,
			"^0"
		};
	}
};

resource 'ALRT' (128, "Info") {
	{40, 40, 182, 366},
	128,
	{	/* array: 4 elements */
		/* [1] */
		OK, visible, sound1;
		/* [2] */
		OK, visible, sound1;
		/* [3] */
		OK, visible, sound1;
		/* [4] */
		OK, visible, sound1
	},
	centerMainScreen
};
