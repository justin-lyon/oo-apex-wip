@isTest
private class MockSObjectBuilderTest {

	private static String TEST_NAME = 'Raymond Powell';
	private static String TEST_NAME_2 = 'Henery Kennsington';
	private static String TEST_PHONE = '1234567890';
	private static String CHILD_LABEL_OPPORTUNITIES = 'Opportunities';
	private static String FIELD_LABEL_NAME = 'Name';

	@isTest
	static void testBuild_hasStarterSObject_shouldMaintainPreviousFields() {
		Account acc = new Account(Owner = new User(), Phone = TEST_PHONE);
		MockSObjectBuilder mockAccountBuilder = new MockSObjectBuilder(acc);

		mockAccountBuilder.setField('Name', TEST_NAME);

		Test.startTest();
		Account mockAccount = (Account) mockAccountBuilder.build();
		Test.stopTest();

		System.assertEquals(TEST_NAME, mockAccount.Name, 'Account does not have correct mock set name.');
		System.assertEquals(TEST_PHONE, mockAccount.Phone, 'Account does not have correct previously set phone number.');
		System.assertEquals(new User(), mockAccount.Owner, 'Account does not have previously set Owner.');
	}

	@isTest
	static void testBuild_hasSObjectType_shouldBuildEmptySObject() {

		MockSObjectBuilder mockAccountBuilder = getTestMockAccountBuilder();

		Test.startTest();
		Account mockAccount = (Account) mockAccountBuilder.build();
		Test.stopTest();

		System.assertEquals(new Account(), mockAccount, 'Does not have default implementation of class');
	}

	@isTest
	static void testBuild_hasFieldSet_objectShouldHaveFieldSet() {

		MockSObjectBuilder mockAccountBuilder = getTestMockAccountBuilder();

		SObjectField nameField = Account.Name.getDescribe().getSObjectField();
		mockAccountBuilder.setField(nameField, TEST_NAME);

		Test.startTest();
		Account mockAccount = (Account) mockAccountBuilder.build();
		Test.stopTest();

		System.assertEquals(TEST_NAME, mockAccount.Name, 'Object does not have correct name.');
	}

	@isTest
	static void testBuild_hasReadOnlyFieldSet_objectShouldHaveFieldSet() {

		MockSObjectBuilder mockUserBuilder = getTestMockUserBuilder();

		SObjectField readOnlyField = User.Name.getDescribe().getSObjectField();
		mockUserBuilder.setField(readOnlyField, TEST_NAME);

		Test.startTest();
		User mockUser = (User) mockUserBuilder.build();
		Test.stopTest();

		System.assertEquals(TEST_NAME, mockUser.Name, 'Object does not have correct Name.');
	}

	@isTest
	static void testBuild_givenChild_objectShouldHaveChild() {

		MockSObjectBuilder mockAccountBuilder = getTestMockAccountBuilder();

		mockAccountBuilder.setChild(CHILD_LABEL_OPPORTUNITIES, getSerializedOpp(TEST_NAME));

		Test.startTest();
		Account mockAccount = (Account) mockAccountBuilder.build();
		Test.stopTest();

		System.assertEquals(TEST_NAME, mockAccount.Opportunities[0].Name, 'Object does not have child');
	}

	@isTest
	static void testBuild_given2Children_objectShouldHave2Children() {

		MockSObjectBuilder mockAccountBuilder = getTestMockAccountBuilder();

		List<String> serializedChildren = new List<String>{getSerializedOpp(TEST_NAME), getSerializedOpp(TEST_NAME_2)};

		System.debug('CHILD REL: '+mockAccountBuilder.getChildRelationship(CHILD_LABEL_OPPORTUNITIES));

		mockAccountBuilder.setChildren(CHILD_LABEL_OPPORTUNITIES, serializedChildren);

		Test.startTest();
		Account mockAccount = (Account) mockAccountBuilder.build();
		Test.stopTest();

		System.assertEquals(TEST_NAME, mockAccount.Opportunities[0].Name, 'Object does not have first child');
		System.assertEquals(TEST_NAME_2, mockAccount.Opportunities[1].Name, 'Object does not have second child');
	}

	@isTest
	static void testGetSerializedSObject_givenEmptyObject_shouldReturnEmptyObject() {

		MockSObjectBuilder mockAccountBuilder = getTestMockAccountBuilder();

		Test.startTest();
		String accountJson = mockAccountBuilder.getSerializedSObject();
		Test.stopTest();

		System.assertEquals(JSON.serialize(new Account()), accountJson);
	}

	@isTest
	static void testSetField_givenField_shouldHaveField() {

		MockSObjectBuilder mockAccountBuilder = getTestMockAccountBuilder();
		SObjectField nameField = Account.Name.getDescribe().getSObjectField();

		Test.startTest();
		mockAccountBuilder.setField(nameField, TEST_NAME);
		Test.stopTest();

		System.assertEquals(TEST_NAME, mockAccountBuilder.getField(nameField), 'Field not found in builder.');
	}

	@isTest
	static void testSetField_givenFieldString_shouldHaveField() {

		MockSObjectBuilder mockAccountBuilder = getTestMockAccountBuilder();
		String nameField = FIELD_LABEL_NAME;

		Test.startTest();
		mockAccountBuilder.setField(nameField, TEST_NAME);
		Test.stopTest();

		System.assertEquals(TEST_NAME, mockAccountBuilder.getField(nameField), 'Field not found in builder.');
	}

	@isTest
	static void testGetMockId_givenNoPreviousIds_shouldReturnFirstId() {

		MockSObjectBuilder mockAccountBuilder = getTestMockAccountBuilder();

		Test.startTest();
		Id mockId = mockAccountBuilder.getMockId();
		Test.stopTest();

		System.assertEquals(mockAccountBuilder.mockType.getDescribe().getKeyPrefix() + '000000000001', mockId);
	}

	@isTest
	static void testGetMockId_givenOnePreviousId_shouldReturnSecondId() {

		MockSObjectBuilder mockAccountBuilder = getTestMockAccountBuilder();
		mockAccountBuilder.getMockId();

		Test.startTest();
		Id mockId = mockAccountBuilder.getMockId();
		Test.stopTest();

		System.assertEquals(mockAccountBuilder.mockType.getDescribe().getKeyPrefix() + '000000000002', mockId);
	}

	@isTest
	static void testGetChildRelationship_givenChildRelationshipLabel_shouldReturnChildRelationship() {

		MockSObjectBuilder mockAccountBuilder = getTestMockAccountBuilder();

		Test.startTest();
		ChildRelationship relationship = mockAccountBuilder.getChildRelationship(CHILD_LABEL_OPPORTUNITIES);
		Test.stopTest();

		System.assertEquals(CHILD_LABEL_OPPORTUNITIES, relationship.getRelationshipName());
	}

	private static MockSObjectBuilder getTestMockAccountBuilder() {
		return new MockSObjectBuilder(Account.getSObjectType());
	}

	private static MockSObjectBuilder getTestMockUserBuilder() {
		return new MockSObjectBuilder(User.getSObjectType());
	}

	private static String getSerializedOpp(String name) {
		MockSObjectBuilder mockOpportunityBuilder = new MockSObjectBuilder(Opportunity.getSObjectType());
		mockOpportunityBuilder.setField(FIELD_LABEL_NAME, name);
		return mockOpportunityBuilder.getSerializedSObject();
	}
}