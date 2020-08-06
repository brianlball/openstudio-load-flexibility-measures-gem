# *******************************************************************************
# OpenStudio(R), Copyright (c) 2008-2020, Alliance for Sustainable Energy, LLC.
# All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# (1) Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# (2) Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# (3) Neither the name of the copyright holder nor the names of any contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission from the respective party.
#
# (4) Other than as required in clauses (1) and (2), distributions in any form
# of modifications or other derivative works may not use the "OpenStudio"
# trademark, "OS", "os", or any other confusingly similar designation without
# specific prior written permission from Alliance for Sustainable Energy, LLC.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER(S) AND ANY CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER(S), ANY CONTRIBUTORS, THE
# UNITED STATES GOVERNMENT, OR THE UNITED STATES DEPARTMENT OF ENERGY, NOR ANY OF
# THEIR EMPLOYEES, BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
# OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# *******************************************************************************

# insert your copyright here

require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'minitest/autorun'
require_relative '../measure.rb'
require 'fileutils'

class AddIceStorageToPlantLoopForLoadFlexibilityTest < Minitest::Test
  # def setup
  # end

  # def teardown
  # end

  def test_number_of_arguments_and_argument_names
    # create an instance of the measure
    measure = AddIceStorageToPlantLoopForLoadFlexibility.new

    # create runner with empty OSW
    osw = OpenStudio::WorkflowJSON.new
    runner = OpenStudio::Measure::OSRunner.new(osw)

    # make an empty model
    model = OpenStudio::Model::Model.new

    # get arguments and test that they are what we are expecting
    arguments = measure.arguments(model)
    assert_equal(30, arguments.size)
    assert_equal('objective', arguments[0].name)
    assert_equal('upstream', arguments[1].name)
    assert_equal('storage_capacity', arguments[2].name)
    assert_equal('melt_indicator', arguments[3].name)
    assert_equal('selected_loop', arguments[4].name)
    assert_equal('selected_chiller', arguments[5].name)
    assert_equal('chiller_resize_factor', arguments[6].name)
    assert_equal('chiller_limit', arguments[7].name)
    assert_equal('old', arguments[8].name)
    assert_equal('ctes_av', arguments[9].name)
    assert_equal('ctes_sch', arguments[10].name)
    assert_equal('chill_sch', arguments[11].name)
    assert_equal('new', arguments[12].name)
    assert_equal('loop_sp', arguments[13].name)
    assert_equal('inter_sp', arguments[14].name)
    assert_equal('chg_sp', arguments[15].name)
    assert_equal('delta_t', arguments[16].name)
    assert_equal('ctes_season', arguments[17].name)
    assert_equal('discharge_start', arguments[18].name)
    assert_equal('discharge_end', arguments[19].name)
    assert_equal('charge_start', arguments[20].name)
    assert_equal('charge_end', arguments[21].name)
    assert_equal('wknds', arguments[22].name)
    assert_equal('report_freq', arguments[23].name)
    assert_equal('dr', arguments[24].name)
    assert_equal('dr_add_shed', arguments[25].name)
    assert_equal('dr_date', arguments[26].name)
    assert_equal('dr_time', arguments[27].name)
    assert_equal('dr_dur', arguments[28].name)
    assert_equal('dr_chill', arguments[29].name)
  end

  def test_bad_argument_values
    # create an instance of the measure
    measure = AddIceStorageToPlantLoopForLoadFlexibility.new

    # create runner with empty OSW
    osw = OpenStudio::WorkflowJSON.new
    runner = OpenStudio::Measure::OSRunner.new(osw)

    # make an empty model
    model = OpenStudio::Model::Model.new

    # get arguments
    arguments = measure.arguments(model)
    argument_map = OpenStudio::Measure.convertOSArgumentVectorToMap(arguments)

    # create hash of argument values
    args_hash = {}

    # populate argument with specified hash value if specified
    arguments.each do |arg|
      temp_arg_var = arg.clone
      if args_hash.key?(arg.name)
        assert(temp_arg_var.setValue(args_hash[arg.name]))
      end
      argument_map[arg.name] = temp_arg_var
    end

    # run the measure
    measure.run(model, runner, argument_map)
    result = runner.result

    # show the output
    show_output(result)

    # assert that it failed
    assert_equal('Fail', result.value.valueName)
    assert(result.errors.size == 2)
  end

  def test_good_argument_values
    # create an instance of the measure
    measure = AddIceStorageToPlantLoopForLoadFlexibility.new

    # create runner with empty OSW
    osw = OpenStudio::WorkflowJSON.new
    runner = OpenStudio::Measure::OSRunner.new(osw)

    # load the test model
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = "#{File.dirname(__FILE__)}/ice_test_model.osm"
    model = translator.loadModel(path)
    assert(!model.empty?)
    model = model.get

    # get arguments
    arguments = measure.arguments(model)
    argument_map = OpenStudio::Measure.convertOSArgumentVectorToMap(arguments)

    # create hash of argument values.
    # If the argument has a default that you want to use, you don't need it in the hash
    args_hash = {}
    args_hash['objective'] = 'Full Storage'
    args_hash['upstream'] = 'Chiller'
    args_hash['storage_capacity'] = 550
    args_hash['melt_indicator'] = 'InsideMelt'
    args_hash['chiller_resize_factor'] = 0.75
    args_hash['chiller_limit'] = 0.7
    args_hash['chg_sp'] = 26
    args_hash['loop_sp'] = 42
    args_hash['delta_t'] = '16'
    args_hash['old'] = false
    args_hash['new'] = true
    args_hash['ctes_season'] = '06/15 - 08/25'
    args_hash['discharge_start'] = '13:00'
    args_hash['discharge_end'] = '18:00'
    args_hash['charge_start'] = '21:30'
    args_hash['charge_end'] = '05:30'
    args_hash['wknds'] = true
    # using defaults values from measure.rb for other arguments

    # populate argument with specified hash value if specified
    arguments.each do |arg|
      temp_arg_var = arg.clone
      if args_hash.key?(arg.name)
        assert(temp_arg_var.setValue(args_hash[arg.name]))
      end
      argument_map[arg.name] = temp_arg_var
    end

    # run the measure
    measure.run(model, runner, argument_map)
    result = runner.result

    # show the output
    show_output(result)

    # assert that it ran correctly
    assert_equal('Success', result.value.valueName)
    assert(result.info.size == 17)
    assert(result.warnings.size == 2)
    assert(result.errors.empty?)

    # save the model to test output directory
    output_file_path = "#{File.dirname(__FILE__)}//output/test_output.osm"
    model.save(output_file_path, true)
  end
end
