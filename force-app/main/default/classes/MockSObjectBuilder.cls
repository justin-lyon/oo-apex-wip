public with sharing class MockSObjectBuilder {

	public SObjectType mockType {get; private set;}

	private String starterSObject;

	private static Integer idCount = 1;

	private Map<SObjectField, String> fieldToValue = new Map<SObjectField, String>();
	private Map<ChildRelationship, List<String>> relationshipToChild = new Map<ChildRelationship, List<String>>();

	public MockSObjectBuilder(SObjectType type) {
		mockType = type;
	}

	public MockSObjectBuilder(SObject starterObject) {
		mockType = starterObject.getSObjectType();
		starterSObject = JSON.serialize(starterObject);
	}

	public MockSObjectBuilder setField(SObjectField field, String value) {
		fieldToValue.put(field, value);
		return this;
	}

	public MockSObjectBuilder setField(String field, String value) {
		SObjectField describeField = getDescribeFieldFromString(field);
		setField(describeField, value);
		return this;
	}

	public String getField(SObjectField field) {

		String value = '';

		if (fieldToValue.containsKey(field)) {
			value = fieldToValue.get(field);
		}
		return value;
	}

	public String getField(String field) {
		SObjectField describeField = getDescribeFieldFromString(field);
		return getField(describeField);
	}

	private SObjectField getDescribeFieldFromString(String field) {
		return mockType.getDescribe().fields.getMap().get(field);
	}

	public String getMockId() {
		return getMockId(mockType);
	}

	public static String getMockId(SObjectType objectType) {

		String nextIdCount = String.valueOf(idCount++);

		return objectType.getDescribe().getKeyPrefix()
		+ getFillerZeros(nextIdCount)
		+ nextIdCount;
	}

	private static String getFillerZeros(String nextIdCount) {
		return '0'.repeat(12-nextIdCount.length());
	}

	public ChildRelationship getChildRelationship(String childLabel) {

		ChildRelationship relationship;

		for (ChildRelationship childRel : mockType.getDescribe().getChildRelationships()) {
			if (childRel.getRelationshipName() == childLabel) {
				relationship = childRel;
			}
		}

		return relationship;
	}

	public MockSObjectBuilder setChild(String childLabel, String serializedChild) {
		return setChild(getChildRelationship(childLabel), serializedChild);
	}

	public MockSObjectBuilder setChildren(String childLabel, List<String> serializedChildren) {
		return setChildren(getChildRelationship(childLabel), serializedChildren);
	}

	public MockSObjectBuilder setChild(ChildRelationship childRel, String serializedChild) {
		setChildren(childRel, new List<String>{serializedChild});
		return this;
	}

	public MockSObjectBuilder setChildren(ChildRelationship childRel, List<String> serializedChildren) {
		if (!relationshipToChild.containsKey(childRel)) {
			relationshipToChild.put(childRel, new List<String>());
		}
		for (String child : serializedChildren) {
			relationshipToChild.get(childRel).add(child);
		}
		return this;
	}

	public SObject build() {

		String jsonSObject = getSerializedSObject();

		SObject mockObject = (SObject) JSON.deserialize(jsonSObject, SObject.class);

		return mockObject;
	}

	public String getSerializedSObject() {

	String jsonSObject = '';

	if (starterSObject == null) {
		jsonSObject = JSON.serialize(mockType.newSObject());
		} else {
			jsonSObject = starterSObject;
		}

		jsonSObject = openJson(jsonSObject)
		+ appendJsonFields()
		+ appendChildRelationships()
		+ closeJson();

		return jsonSObject;
	}

	private String openJson(String jsonSObject) {
		return jsonSObject.substring(0, jsonSObject.length() - 1);
	}

	private String appendJsonFields() {
		String fieldsToAppend = '';
		for (SObjectField field : fieldToValue.keySet()) {
			fieldsToAppend += ',"' + field + '":"' + fieldToValue.get(field) + '"';
		}
		return fieldsToAppend;
	}

	private String appendChildRelationships() {
		String childrenToAppend = '';
		for (ChildRelationship relationship : relationshipToChild.keySet()) {
			List<String> serializedChildren = relationshipToChild.get(relationship);
			childrenToAppend += getRelationshipName(relationship)
			+ getRelationshipHeaderInfo(serializedChildren.size())
			+ getRecordStart()
			+ getChildRecords(serializedChildren)
			+ closeChildList();
		}
		return childrenToAppend;
	}

	private String getRelationshipName(ChildRelationship relationship) {
		return ',"' + relationship.getRelationshipName() + '":{';
	}

	private String getRelationshipHeaderInfo(Integer childCount) {
		return'"totalSize":' + childCount + ',"done":true,';
	}

	private String getRecordStart() {
		return '"records":[';
	}

	private String getChildRecords(List<String> serializedChildren) {
		String childRecords = '';
		for (String child : serializedChildren) {
			childRecords += child + ',';
		}
		childRecords = childRecords.substring(0, childRecords.length() - 1);
		return childRecords;
	}

	private String closeChildList() {
		return ']}';
	}

	private String closeJson() {
		return '}';
	}
}