trigger Account on Account (before insert) {
	if (TriggerBypass.isActive(AccountFacade.TRIGGER_NAME)) {
		AccountFacade facade = new AccountFacade();

		if (Trigger.IsInsert) {
			if (Trigger.IsBefore) {

				facade.beforeInsert(Trigger.new);

			} else if (Trigger.IsAfter) {

				facade.afterInsert(Trigger.new);

			}
		}

		if (Trigger.IsUpdate) {
			if (Trigger.IsBefore) {

				facade.beforeUpdate(Trigger.new, Trigger.oldMap);

			} else if (Trigger.IsAfter) {

				facade.afterUpdate(Trigger.new, Trigger.oldMap);

			}

		}

	}
}
