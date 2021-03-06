require File.dirname(__FILE__) + '/../spec_helper'

module RedmineCharts
describe ConditionsUtils do
  before(:all) do
    @utils = RedmineCharts::ConditionsUtils
    @types = @utils.types
  end

  it "should return project_its_subprojects_ids" do
    @utils.project_and_its_children_ids(15041).should == [15041,15042]
  end

  it "should return conditions_types" do
    @utils.types.should == [ :issue_ids, :project_ids, :user_ids, :category_ids, :status_ids, :activity_ids, :fixed_version_ids, :tracker_ids, :priority_ids, :author_ids, :assigned_to_ids ]
  end

  it "should return_proper_conditions" do
    project = Project.find(15041)
    options = @utils.to_options(project, @types)

    options[:user_ids] = options[:user_ids].select { |u| u[1] != 9 }
    options[:assigned_to_ids] = options[:assigned_to_ids].select { |u| u[1] != 9 }
    options[:author_ids] = options[:author_ids].select { |u| u[1] != 9 }

    options[:issue_ids].should be_nil
    options[:project_ids].should == [["Project1", 15041], ["Project2", 15042]]
    options[:user_ids].should == [["Dave Lopper", 15043], ["John Smith", 15042], ["Redmine Admin", 15041]]
    options[:assigned_to_ids].should == [["Dave Lopper", 15043], ["John Smith", 15042], ["Redmine Admin", 15041]]
    options[:author_ids].should == [["Dave Lopper", 15043], ["John Smith", 15042], ["Redmine Admin", 15041]]
    options[:activity_ids].should == [["Design", 8], ["Development", 9]]
    options[:category_ids].should == [["Project1 - Category1", 15041], ["Project1 - Category2", 15042], ["Project2 - Category3", 15043]]
    options[:fixed_version_ids].should == [["Project1 - 1.0", 15041], ["Project1 - 2.0", 15042]]
    options[:tracker_ids].should == [["Bug", 1], ["Feature", 2], ["Support", 3]]
    options[:priority_ids].should == [["High", 3], ["Immediate", 5], ["Low", 1], ["Normal", 2], ["Urgent", 4]]
    options[:status_ids].should == [["Assigned", 2], ["Closed", 5], ["Feedback", 4], ["New", 1], ["Rejected", 6], ["Resolved", 3]]
  end

  it "should set project_ids if not provided in params" do
    conditions = @utils.from_params(@types, 15041, {})
    conditions[:project_ids].should == [15041, 15042]
  end

  it "should set project_ids if provided empty project in params" do
    conditions = @utils.from_params(@types, 15041, {:project_ids => []})
    conditions[:project_ids].should == [15041, 15042]
  end

  it "should set project_ids if provided wronghin params" do
    conditions = @utils.from_params(@types, 15041, {:project_ids => [0, nil, 15041, 15043, 15099],})
    conditions[:project_ids].should == [15041, 15043]
  end

  it "should read project_ids from params" do
    conditions = @utils.from_params(@types, 15041, {:project_ids => [15041, 15042, 15043]})
    conditions[:project_ids].should == [15041,15042,15043]
  end

  it "should read conditions from params" do
    conditions = @utils.from_params(@types, 15041, {:issue_ids => 66, :activity_ids => 12})
    conditions[:issue_ids].should == [66]
    conditions[:activity_ids].should == [12]

  end

  it "should read multiple conditions from params" do
    conditions = @utils.from_params(@types, 15041, {:category_ids => [3, 5, 7]})
    conditions[:category_ids].should == [3, 5, 7]
  end

  it "should remove wrong conditions from params" do
    conditions = @utils.from_params(@types, 15041, {:tracker_ids => [3, 0, nil, 7]})
    conditions[:tracker_ids].should == [3, 7]
  end

  it "should set nil instead of empty array for conditions from params" do
    conditions = @utils.from_params(@types, 15041, {:user_ids => 0, :issue_ids => nil, :author_ids => [0], :priority_ids => [nil], :status_ids => []})
    conditions[:user_ids].should be_nil
    conditions[:issue_ids].should be_nil
    conditions[:author_ids].should be_nil
    conditions[:status_ids].should be_nil
    conditions[:priority_ids].should be_nil
    conditions[:fixed_version_ids].should be_nil
  end

end
end
