# util.mk - Miscellaneous utility functions for use in Makefiles

# Throws an error if the value of the variable named by $(1) is not in the list given by $(2)
define validate-option
  # value must be part of the list
  ifeq ($$(filter $($(1)),$(2)),)
    $$(error Value of $(1) must be one of the following: $(2))
  endif
  # value must be a single word (no whitespace)
  ifneq ($$(words $($(1))),1)
    $$(error Value of $(1) must be one of the following: $(2))
  endif
endef

# Returns the path to the command $(1) if exists. Otherwise returns an empty string.
find-command = $(shell which $(1) 2>/dev/null)

# List of o files compiled from the same source, but into different module directories, and their dependencies, separated by <o-file>?<dependency>
SPECIAL_O := bf_states?bf_state_definitions.inc.c candidates?state.h interprocess?state.h

MARIO_STEP_OBJECTS := mario_step.o mario.o mario_actions_airborne.o mario_actions_moving.o mario_actions_stationary.o mario_actions_submerged.o

word-dot = $(word $2,$(subst ?, ,$1))

# Rule to compile a SPECIAL_O file
define special
$(eval _2 := $(call word-dot,$2,1))
$(eval _3 := $(call word-dot,$2,2))
$(BUILD_DIR)/bruteforce/$(1)/$(_2).o: bruteforce/$(_2).c bruteforce/$(1)/$(_3)
	$(call print,$(MODULE_PATH),,)
	$(call print,Compiling:,$$<,$$@)
	$(CC_CHECK) $(CC_CHECK_CFLAGS) -DMODULE_PATH=$(1) -MMD -MP -MT $$@ -MF $(BUILD_DIR)/bruteforce/$(1)/$(_2).d $$<
	$(V)$(CC) -c $(CFLAGS) -DMODULE_PATH=$(1) -o $$@ $$<
endef

# Function to register a module from its make.split file
define register-module
$(eval $(NAME)REQUIRED_OBJECTS += $(addprefix bruteforce/, interface.o m64.o readers.o json.o engine_feed.o engine_stubs.o misc_util.o pipeex.o))
$(eval $(NAME)REQUIRED_O_FILES := $(addprefix $(BUILD_DIR)/, $($(NAME)REQUIRED_OBJECTS)))
ALL_TARGETS += $(NAME)
SRC_DIRS += bruteforce/$(NAME)
BIN_DIRS += $(NAME)
$(eval $(NAME): MODULE_PATH := $(NAME))
$(NAME): $($(NAME)REQUIRED_O_FILES)
	$(CC) -o $(BINARY_DIR)/$(NAME)/main.exe $($(NAME)REQUIRED_O_FILES)
	$(CC) -E -CC -P $(foreach i,$(INCLUDE_DIRS),-I$(i)) -DMODULE_PATH=$(NAME) ./bruteforce/generate_state_defintion.c \
	 | sed -e 's/__NL__ /\n/g' -e 's/__NL__//g' > $(BINARY_DIR)/$(NAME)/state_definitions.txt 

$(foreach o,$(SPECIAL_O),$(eval $(call special,$(NAME),$(o))))
$(eval $(call create-state-definition,$(NAME)))
endef