/**
 * AccountFacade.cls
 * Description: Compose business layer into the facade's Trigger Context methods.
 * 	Stateful Facade allows for Dependency Injection.
 */
public with sharing class AccountFacade {
	public static final String TRIGGER_NAME = 'Account';

	public void beforeInsert(List<Account> newAccounts) {
		// Do Before Insert
	}

	public void afterInsert(List<Account> newAccounts) {}

	public void beforeUpdate(List<Account> newAccounts, Map<Id, Account> oldAccounts) {}

	public void afterUpdate(List<Account> newAccounts, Map<Id, Account> oldAccounts) {}
}
