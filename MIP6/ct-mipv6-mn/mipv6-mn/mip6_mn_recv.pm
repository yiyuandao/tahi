#!/usr/bin/perl -w
#
# Copyright (C) IPv6 Promotion Council,
# NIPPON TELEGRAPH AND TELEPHONE CORPORATION (NTT),
# Yokogwa Electoric Corporation, YASKAWA INFORMATION SYSTEMS Corporation
# and NTT Advanced Technology Corporation(NTT-AT) All rights reserved.
# 
# Technology Corporation.
# 
# Redistribution and use of this software in source and binary forms, with 
# or without modification, are permitted provided that the following 
# conditions and disclaimer are agreed and accepted by the user:
# 
# 1. Redistributions of source code must retain the above copyright 
# notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright 
# notice, this list of conditions and the following disclaimer in the 
# documentation and/or other materials provided with the distribution.
# 
# 3. Neither the names of the copyrighters, the name of the project which 
# is related to this software (hereinafter referred to as "project") nor 
# the names of the contributors may be used to endorse or promote products 
# derived from this software without specific prior written permission.
# 
# 4. No merchantable use may be permitted without prior written 
# notification to the copyrighters. However, using this software for the 
# purpose of testing or evaluating any products including merchantable 
# products may be permitted without any notification to the copyrighters.
# 
# 
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHTERS, THE PROJECT AND 
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING 
# BUT NOT LIMITED THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
# FOR A PARTICULAR PURPOSE, ARE DISCLAIMED.  IN NO EVENT SHALL THE 
# COPYRIGHTERS, THE PROJECT OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
# CONTRACT,STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
# THE POSSIBILITY OF SUCH DAMAGE.
#

# PACKAGE
package mip6_mn_recv;

# EXPORT PACKAGE
use Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
	%RECV_PACKET_ECHOREPLY
	%RECV_PACKET_RS
	%RECV_PACKET_RA
	%RECV_PACKET_NS
	%RECV_PACKET_DAD
	%RECV_PACKET_NA
	%RECV_PACKET_HAADREQUEST
	%RECV_PACKET_MPS
	%RECV_PACKET_HOT
	%RECV_PACKET_HOTI
	%RECV_PACKET_COT
	%RECV_PACKET_COTI
	%RECV_PACKET_BU
	%RECV_PACKET_BU_CN
	vRecv_at_Link0
	vRecv_at_Link0_NonHA
	vRecv_at_LinkX
	vRecv_at_LinkY
	vRecv_at_Link0_return
	vRecv_to_establish_SA_at_LinkX
	vRecv_to_establish_all_SA_at_LinkX
	vRecv_to_detect_movement_at_LinkX
	vRecv_to_detect_movement_at_LinkY
	vRecv_to_detect_movement_at_Link0
	vRecv_to_move_from_Link0_to_LinkX
	vRecv_to_move_from_Link0_to_LinkX_NonHA
	vRecv_to_move_from_Link0_to_LinkX_w_all_SA
	vRecv_to_move_from_LinkX_to_LinkY
	vRecv_to_move_from_LinkX_to_Link0
	vRecv_to_move_from_LinkY_to_Link0
	CorrespondentRegistration_to_mn_at_LinkX
	CorrespondentRegistration_to_mn_at_LinkY
	Init_MN
	Term_MN
);

# INPORT PACKAGE
use V6evalTool;
use IKEapi;
use mip6_mn_config;
use mip6_mn_get;
use mip6_mn_ike;
use mip6_mn_common;
use mip6_mn_send;
use mip6_mn_neighbor;


# GLOBAL VARIABLE DEFINITION
%RECV_PACKET_ECHOREPLY   = ();
%RECV_PACKET_NS          = ();
%RECV_PACKET_DAD         = ();
%RECV_PACKET_NA          = ();
%RECV_PACKET_HAADREQUEST = ();
%RECV_PACKET_MPS         = ();
%RECV_PACKET_HOT         = ();
%RECV_PACKET_HOTI        = ();
%RECV_PACKET_COT         = ();
%RECV_PACKET_COTI        = ();
%RECV_PACKET_BU          = ();
%RECV_PACKET_BU_CN       = ();

# LOCAL VARIABLE DEFINITION
# The packet to specify and its order at Link0
my @recv_packets_at_link0 = ();

# The packet to specify and its order at Link0 NonHA
my @recv_packets_at_link0_NonHA = ();

# The packet to specify and its order at LinkX
my @recv_packets_at_linkx = ();

# The packet to specify and its order at LinkY
my @recv_packets_at_linky = ();

# The packet to specify and its order at Link0 return
my @recv_packets_at_link0_return = ();

# The packet to specify and its order at Link0 detect
my @recv_packets_at_link0_detect = ();

# The packet to specify and its order at Link0 move
my @recv_packets_at_link0_move = ();

# The receive packet and related data at Link0XY
my %recv_packet_process = (
	# echoreply
	'echoreply_nuthga_cn0ga' => {
		'store' => 'RECV_PACKET_ECHOREPLY',
		'func'  => 'vSend_noreply',
		'msg'   => 'none',
	},
	'echoreply_nutxga_cn0ga' => {
		'store' => 'RECV_PACKET_ECHOREPLY',
		'func'  => 'vSend_noreply',
		'msg'   => 'none',
	},
	'echoreply_nuthga_cn0ga_tnl_nutx_ha0' => {
		'store' => 'RECV_PACKET_ECHOREPLY',
		'func'  => 'vSend_noreply',
		'msg'   => 'none',
	},
	'echoreply_nutxga_cn0ga_hoa_nuthga' => {
		'store' => 'RECV_PACKET_ECHOREPLY',
		'func'  => 'vSend_noreply',
		'msg'   => 'none',
	},
	'echoreply_nutyga_cn0ga' => {
		'store' => 'RECV_PACKET_ECHOREPLY',
		'func'  => 'vSend_noreply',
		'msg'   => 'none',
	},
	'echoreply_nuthga_cn0ga_tnl_nuty_ha0' => {
		'store' => 'RECV_PACKET_ECHOREPLY',
		'func'  => 'vSend_noreply',
		'msg'   => 'none',
	},
	'echoreply_nutyga_cn0ga_hoa_nuthga' => {
		'store' => 'RECV_PACKET_ECHOREPLY',
		'func'  => 'vSend_noreply',
		'msg'   => 'none',
	},
	'echoreply_nuthga_cn0yga_rh2_cn0ga_tnl_nutany_ha0' => {
		'store' => 'RECV_PACKET_ECHOREPLY',
		'func'  => 'vSend_noreply',
		'msg'   => 'none',
	},
	'echoreply_nutxga_cn0yga_rh2_cn0ga_hoa_nuthga' => {
		'store' => 'RECV_PACKET_ECHOREPLY',
		'func'  => 'vSend_noreply',
		'msg'   => 'none',
	},
	'echoreply_nutyga_cn0yga_rh2_cn0ga_hoa_nuthga' => {
		'store' => 'RECV_PACKET_ECHOREPLY',
		'func'  => 'vSend_noreply',
		'msg'   => 'none',
	},

	# rs
	'rs_any_any' => {
		'store' => 'RECV_PACKET_RS',
		'func'  => 'vReply_rs',
		'msg'   => '*',
	},
	'rs_any_any_opt_any' => {
		'store' => 'RECV_PACKET_RS',
		'func'  => 'vReply_rs',
		'msg'   => '*',
	},

	# ra
	'ra_any_any' => {
		'store' => 'RECV_PACKET_RA',
		'func'  => 'vReply_ra',
		'msg'   => '*',
	},
	'ra_any_any_opt_any' => {
		'store' => 'RECV_PACKET_RA',
		'func'  => 'vReply_ra',
		'msg'   => '*',
	},

	# ns
	'ns_any_any' => {
		'store' => 'RECV_PACKET_NS',
		'func'  => 'vReply_ns',
		'msg'   => '*',
	},
	'ns_any_any_w_ipsec' => {
		'store' => 'RECV_PACKET_NS',
		'func'  => 'vReply_ns',
		'msg'   => '*',
	},
	'ns_any_any_opt_any' => {
		'store' => 'RECV_PACKET_NS',
		'func'  => 'vReply_ns',
		'msg'   => '*',
	},
	'ns_any_any_opt_any_w_ipsec' => {
		'store' => 'RECV_PACKET_NS',
		'func'  => 'vReply_ns',
		'msg'   => '*',
	},

	# na
	'na_any_any' => {
		'store' => 'RECV_PACKET_NA',
		'func'  => 'vReply_na',
		'msg'   => '*',
	},
	'na_any_any_opt_any' => {
		'store' => 'RECV_PACKET_NA',
		'func'  => 'vReply_na',
		'msg'   => '*',
	},

	# haadrequest
	'haadrequest_nut0lla_link0haany' => {
		'store' => 'RECV_PACKET_HAADREQUEST',
		'func'  => 'vSend_haadreply',
		'msg'   => 'haadreply_ha0lla_nut0lla_list_ha0',
	},
	'haadrequest_nuthga_link0haany' => {
		'store' => 'RECV_PACKET_HAADREQUEST',
		'func'  => 'vSend_haadreply',
		'msg'   => 'haadreply_ha0ga_nuthga_list_ha0',
	},
	'haadrequest_nutxga_link0haany' => {
		'store' => 'RECV_PACKET_HAADREQUEST',
		'func'  => 'vSend_haadreply',
		'msg'   => 'haadreply_ha0ga_nutxga_list_ha0',
	},
	'haadrequest_nutyga_link0haany' => {
		'store' => 'RECV_PACKET_HAADREQUEST',
		'func'  => 'vSend_haadreply',
		'msg'   => 'haadreply_ha0ga_nutyga_list_ha0',
	},

	# mps
	'mps_nutxga_ha0ga_hoa_nuthga' => {
		'store' => 'RECV_PACKET_MPS',
		'func'  => 'vSend_mpa',
		'msg'   => 'mpa_ha0ga_nutxga_rh2_nuthga_pfx_ha0',
	},
	'mps_nutyga_ha0ga_hoa_nuthga' => {
		'store' => 'RECV_PACKET_MPS',
		'func'  => 'vSend_mpa',
		'msg'   => 'mpa_ha0ga_nutyga_rh2_nuthga_pfx_ha0',
	},

	# brr
	'brr_nuthga_cn0ga_tnl_nutx_ha0' => {
		'store' => 'RECV_PACKET_BRR',
		'func'  => 'vSend_noreply',
		'msg'   => 'none',
	},
	'brr_nuthga_cn0ga_tnl_nuty_ha0' => {
		'store' => 'RECV_PACKET_BRR',
		'func'  => 'vSend_noreply',
		'msg'   => 'none',
	},

	# hoti
	'hoti_nuthga_cn0ga' => {
		'store' => 'RECV_PACKET_HOTI',
		'func'  => 'vSend_hot',
		'msg'   => 'hot_cn0ga_nuthga',
	},
	'hoti_nuthga_cn0ga_tnl_nuth_ha0' => {
		'store' => 'RECV_PACKET_HOTI',
		'func'  => 'vSend_hot',
		'msg'   => 'hot_cn0ga_nuthga',
	},
	'hoti_nuthga_cn0ga_tnl_nutx_ha0' => {
		'store' => 'RECV_PACKET_HOTI',
		'func'  => 'vSend_hot',
		'msg'   => 'hot_cn0ga_nuthga_tnl_ha0_nutx',
	},
	'hoti_nuthga_cn0ga_tnl_nuty_ha0' => {
		'store' => 'RECV_PACKET_HOTI',
		'func'  => 'vSend_hot',
		'msg'   => 'hot_cn0ga_nuthga_tnl_ha0_nuty',
	},

	# coti
	'coti_nutxga_cn0ga' => {
		'store' => 'RECV_PACKET_COTI',
		'func'  => 'vSend_cot',
		'msg'   => 'cot_cn0ga_nutxga',
	},
	'coti_nutyga_cn0ga' => {
		'store' => 'RECV_PACKET_COTI',
		'func'  => 'vSend_cot',
		'msg'   => 'cot_cn0ga_nutyga',
	},

	# hot
	'hot_nuthga_cn0ga_tnl_nutx_ha0' => {
		'store' => 'RECV_PACKET_HOT',
		'func'  => 'vSend_noreply',
		'msg'   => 'none',
	},
	'hot_nuthga_cn0ga_tnl_nuty_ha0' => {
		'store' => 'RECV_PACKET_HOT',
		'func'  => 'vSend_noreply',
		'msg'   => 'none',
	},

	# cot
	'cot_nuthga_cn0yga_tnl_nuty_ha0' => {
		'store' => 'RECV_PACKET_COT',
		'func'  => 'vSend_noreply',
		'msg'   => 'none',
	},
	'cot_nuthga_cn0yga_tnl_nutx_ha0' => {
		'store' => 'RECV_PACKET_COT',
		'func'  => 'vSend_noreply',
		'msg'   => 'none',
	},

	# bu
	'bu_nuthga_ha0ga' => {
		'store' => 'RECV_PACKET_BU',
		'func'  => 'vSend_ba',
		'msg'   => 'ba_ha0ga_nuthga',
	},
	'bu_nuthga_ha0ga_hoa_nuthga' => {
		'store' => 'RECV_PACKET_BU',
		'func'  => 'vSend_ba',
		'msg'   => 'ba_ha0ga_nuthga',
	},
	'bu_nutxga_ha0ga_hoa_nuthga' => {
		'store' => 'RECV_PACKET_BU',
		'func'  => 'vSend_ba',
		'msg'   => 'ba_ha0ga_nutxga_rh2_nuthga',
	},
	'bu_nutyga_ha0ga_hoa_nuthga' => {
		'store' => 'RECV_PACKET_BU',
		'func'  => 'vSend_ba',
		'msg'   => 'ba_ha0ga_nutyga_rh2_nuthga',
	},

	# bu cn
	'bu_nuthga_cn0ga' => {
		'store' => 'RECV_PACKET_BU_CN',
		'func'  => 'vSend_ba_cn',
		'msg'   => 'ba_cn0ga_nuthga',
	},
	'bu_nuthga_cn0ga_hoa_nuthga' => {
		'store' => 'RECV_PACKET_BU_CN',
		'func'  => 'vSend_ba_cn',
		'msg'   => 'ba_cn0ga_nuthga',
	},
	'bu_nutxga_cn0ga_hoa_nuthga' => {
		'store' => 'RECV_PACKET_BU_CN',
		'func'  => 'vSend_ba_cn',
		'msg'   => 'ba_cn0ga_nutxga_rh2_nuthga',
	},
	'bu_nutxga_cn0ga_hoa_nuthga_coa_nutx' => {
		'store' => 'RECV_PACKET_BU_CN',
		'func'  => 'vSend_ba_cn',
		'msg'   => 'ba_cn0ga_nutxga_rh2_nuthga',
	},
	'bu_nutyga_cn0ga_hoa_nuthga' => {
		'store' => 'RECV_PACKET_BU_CN',
		'func'  => 'vSend_ba_cn',
		'msg'   => 'ba_cn0ga_nutyga_rh2_nuthga',
	},
	'bu_nutyga_cn0ga_hoa_nuthga_coa_nuty' => {
		'store' => 'RECV_PACKET_BU_CN',
		'func'  => 'vSend_ba_cn',
		'msg'   => 'ba_cn0ga_nutyga_rh2_nuthga',
	},

	# ba_cn
	'ba_nuthga_cn0yga_rh2_cn0ga_tnl_nutx_ha0' => {
		'store' => 'RECV_PACKET_BA_CN',
		'func'  => 'vSend_noreply',
		'msg'   => 'none',
	},
	'ba_nuthga_cn0yga_rh2_cn0ga_tnl_nuty_ha0' => {
		'store' => 'RECV_PACKET_BA_CN',
		'func'  => 'vSend_noreply',
		'msg'   => 'none',
	},

	# be
);

# SUBROUTINE DECLARATION
sub vRecv_at_Link0($$@);
sub vRecv_at_Link0_NonHA($$@);
sub vRecv_at_LinkX($$@);
sub vRecv_at_LinkY($$@);
sub vRecv_at_Link0_return($$@);
sub vRecv_to_establish_SA_at_LinkX($$);
sub vRecv_to_establish_all_SA_at_LinkX($);
sub vRecv_to_detect_movement_at_LinkX($$);
sub vRecv_to_detect_movement_at_LinkY($$);
sub vRecv_to_detect_movement_at_Link0($$);
sub vRecv_to_move_from_Link0_to_LinkX($);
sub vRecv_to_move_from_Link0_to_LinkX_NonHA($);
sub vRecv_to_move_from_Link0_to_LinkX_w_all_SA($);
sub vRecv_to_move_from_LinkX_to_LinkY($);
sub vRecv_to_move_from_LinkX_to_Link0($);
sub vRecv_to_move_from_LinkY_to_Link0($);
sub CorrespondentRegistration_to_mn_at_LinkX($$$$);
sub CorrespondentRegistration_to_mn_at_LinkY($$$$);
sub set_default_recv_packet();
sub Init_MN(@);
sub Term_MN(@);


# SUBROUTINE
#-----------------------------------------------------------------------------#
# vRecv_at_Link0($$@)
#
# <in>  $if     : Interface
#       $timeout: Timeout [sec]
#       @packets: Expect Packets
#
# <out> %recv_pakect: = vRecv();
#-----------------------------------------------------------------------------#
sub vRecv_at_Link0($$@) {
	my ($if, $timeout, @packets) = @_;
	my %recv_packet;
	my $recv_process;
	my $sec;
	my $ra_flag = 0;

	# Real Home Link
	if ($MN_CONF{TEST_FUNC_REAL_HOME_LINK} ne 'YES') {
		$packet{status} = 0;
		return (%packet);
	}

	# check new Link
	if (set_now_link("Link0") == 1) {
		# First RA at Link0
		%SEND_PACKET_RA_LINK0 = vSend_ra($if, 'ra_ha0lla_allnodemcast_sll_ha0_mtu_pfx_ha0ga_hainfo', 0);
	}

	# dummy route for debug
	if ($MN_CONF{'ENV_IKE_WO_IKE'} == 1) {
		set_sa();
		if ($UP_SA_CHECKER ne '') {
			$recv_packet{status} = 2;
			return (%recv_packet);
		}
	}
	# end

	# Timer
	if ($timeout <= 0) {
		$timeout = 1;
	}
	my $now_time = time;
	my $end_time = $now_time + $timeout;

	# wait for expect packet or timeout
	while ($now_time < $end_time) {

		$sec = $end_time - $now_time;
		if ($sec > $IF0_Recvtime) {
			$sec = $IF0_Recvtime;
		}

		# Receive Link0
		%recv_packet = IKEvRecv($if, $sec, 0, 1,
			@packets,
			@recv_packets_at_link0);

		# save unexpect
		push @UNEXPECT, @{ $recv_packet{'SaUnexpect'} };

		# Known Packet
		if ($recv_packet{ikeStatus} eq 'StUserFrame') {
			# set default process & global
			if ($recv_packet_process{$recv_packet{recvFrame}} ne undef) {
				$recv_process = $recv_packet_process{$recv_packet{recvFrame}};
				%{$recv_process->{store}} = %recv_packet;
			}

			# BINGO !!
			foreach $_ (@packets) {
				if ($recv_packet{recvFrame} eq $_) {
					return (%recv_packet);
				}
			}

			# default process
			&{$recv_process->{func}}($if, $recv_process->{msg}, \%recv_packet);

			# close to sending time of target
			$now_time = $recv_packet{recvTime1};

			# for return at timeout
			$recv_packet{status} = 2;
		}
		# IKE event
		elsif ($recv_packet{ikeStatus} eq 'StCallBack') {
			# for return at timeout
			$recv_packet{status} = 2;
			return (%recv_packet);
		}
		# Timeout
		elsif ($recv_packet{ikeStatus} eq 'StTimeOut') {
			# close to sending time of target
			$now_time += $sec;
			if ($sec >= $MinDelayBetweenRAs) {
				$ra_flag = 1;
			}

			# for return at timeout
			$recv_packet{recvTime1} = $now_time;
		}
#		# Unexpect Packet
#		elsif ($recv_packet{status} == 2) {
#			# close to sending time of target
#			$now_time = $recv_packet{recvTime1};
#
#			# check unexpect at the end
#			$recv_packet{'vRecvPKT'} = $V6evalTool::vRecvPKT;
#			push @UNEXPECT, { %recv_packet };
#		}
		# Internal Error
		else {
			vLogHTML_Fail("vRecv internal error.");
			exit $V6evalTool::exitFatal;
		}

		# Unsol RA
		if ($ra_flag == 0) {
			$wk = time;
			if ($wk >= ($SEND_PACKET_RA{sentTime1} + $MinDelayBetweenRAs)) {
				$ra_flag = 1;
			}
		}
		if ($ra_flag == 1) {
			%SEND_PACKET_RA_LINK0 = vSend_ra($if, 'ra_ha0lla_allnodemcast_sll_ha0_mtu_pfx_ha0ga_hainfo', 0);
			$ra_flag = 0;
		}
	}

	# timeout
	return (%recv_packet);
}

#-----------------------------------------------------------------------------#
# vRecv_at_Link0_NonHA($$@)
#-----------------------------------------------------------------------------#
sub vRecv_at_Link0_NonHA($$@) {
	my ($if, $timeout, @packets) = @_;
	my %recv_packet;
	my $recv_process;
	my $sec;
	my $ra_flag = 0;

	# Real Home Link
	if ($MN_CONF{TEST_FUNC_REAL_HOME_LINK} ne 'YES') {
		$packet{status} = 0;
		return (%packet);
	}

	# Set RA Type
	set_ha1_is_rt();

	# check new Link
	if (set_now_link("Link0") == 1) {
		# First RA at Link0
		%SEND_PACKET_RA_LINK0 = vSend_ra($if, 'ra_ha0lla_allnodemcast_sll_ha0_mtu_pfx_link0', 0);
	}

	# dummy route for debug
	if ($MN_CONF{'ENV_IKE_WO_IKE'} == 1) {
		set_sa();
		if ($UP_SA_CHECKER ne '') {
			$recv_packet{status} = 2;
			return (%recv_packet);
		}
	}
	# end

	# Timer
	if ($timeout <= 0) {
		$timeout = 1;
	}
	my $now_time = time;
	my $end_time = $now_time + $timeout;

	# wait for expect packet or timeout
	while ($now_time < $end_time) {

		$sec = $end_time - $now_time;
		if ($sec > $IF0_Recvtime) {
			$sec = $IF0_Recvtime;
		}

		# Receive Link0
		%recv_packet = IKEvRecv($if, $sec, 0, 1,
			@packets,
			@recv_packets_at_link0_NonHA);

		# save unexpect
		push @UNEXPECT, @{ $recv_packet{'SaUnexpect'} };

		# Known Packet
		if ($recv_packet{ikeStatus} eq 'StUserFrame') {
			# set default process & global
			if ($recv_packet_process{$recv_packet{recvFrame}} ne undef) {
				$recv_process = $recv_packet_process{$recv_packet{recvFrame}};
				%{$recv_process->{store}} = %recv_packet;
			}

			# BINGO !!
			foreach $_ (@packets) {
				if ($recv_packet{recvFrame} eq $_) {
					unset_ha1_is_rt();
					return (%recv_packet);
				}
			}

			# default process
			&{$recv_process->{func}}($if, $recv_process->{msg}, \%recv_packet);

			# close to sending time of target
			$now_time = $recv_packet{recvTime1};

			# for return at timeout
			$recv_packet{status} = 2;
		}
		# IKE event
		elsif ($recv_packet{ikeStatus} eq 'StCallBack') {
			# for return at timeout
			$recv_packet{status} = 2;
			return (%recv_packet);
		}
		# Timeout
		elsif ($recv_packet{ikeStatus} eq 'StTimeOut') {
			# close to sending time of target
			$now_time += $sec;
			if ($sec >= $MinDelayBetweenRAs) {
				$ra_flag = 1;
			}

			# for return at timeout
			$recv_packet{recvTime1} = $now_time;
		}
#		# Unexpect Packet
#		elsif ($recv_packet{status} == 2) {
#			# close to sending time of target
#			$now_time = $recv_packet{recvTime1};
#
#			# check unexpect at the end
#			$recv_packet{'vRecvPKT'} = $V6evalTool::vRecvPKT;
#			push @UNEXPECT, { %recv_packet };
#		}
		# Internal Error
		else {
			vLogHTML_Fail("vRecv internal error.");
			exit $V6evalTool::exitFatal;
		}

		# Unsol RA
		if ($ra_flag == 0) {
			$wk = time;
			if ($wk >= ($SEND_PACKET_RA{sentTime1} + $MinDelayBetweenRAs)) {
				$ra_flag = 1;
			}
		}
		if ($ra_flag == 1) {
			%SEND_PACKET_RA_LINK0 = vSend_ra($if, 'ra_ha0lla_allnodemcast_sll_ha0_mtu_pfx_link0', 0);
			$ra_flag = 0;
		}
	}

	# timeout
	unset_ha1_is_rt();
	return (%recv_packet);
}

#-----------------------------------------------------------------------------#
# vRecv_at_LinkX($$@)
#-----------------------------------------------------------------------------#
sub vRecv_at_LinkX($$@) {
	my ($if, $timeout, @packets) = @_;
	my %recv_packet;
	my $recv_process;
	my $sec;
	my %hoti_packet;
	my $hoti_flag = 0;
	my $hotis_flag = 0;
	my $coti_flag = 0;
	my $ra_flag = 0;

	my %hot_packet;        # Mobile to Mobile
	my %cot_packet;        # Mobile to Mobile
	my $hots_flag = 0;     # Mobile to Mobile
	my $hot_flag = 0;      # Mobile to Mobile
	my $cot_flag = 0;      # Mobile to Mobile

	# check new Link
	if (set_now_link("LinkX") == 1) {
		# First RA at Link0
		if ($MN_CONF{SET_RA_RBIT} eq 'YES') {
			%SEND_PACKET_RA_LINKX = vSend_ra($if, 'ra_r1lla_allnodemcast_sll_r1_mtu_pfx_r1ga', 0);
		}
		else {
			%SEND_PACKET_RA_LINKX = vSend_ra($if, 'ra_r1lla_allnodemcast_sll_r1_mtu_pfx_linkx', 0);
		}
	}

	# dummy route for debug
#	if ($MN_CONF{'ENV_IKE_WO_IKE'} == 1) {
#		set_sa();
#		if ($UP_SA_CHECKER ne '') {
#			$recv_packet{status} = 2;
#			return (%recv_packet);
#		}
#	}
	# end

	# Timer
	if ($timeout <= 0) {
		$timeout = 1;
	}
	my $now_time = time;
	my $end_time = $now_time + $timeout;

	# wait for expect packet or timeout
	while ($now_time < $end_time) {

		$sec = $end_time - $now_time;
		if ($sec > $IF0_Recvtime) {
			$sec = $IF0_Recvtime;
		}

		# Receive LinkX
		%recv_packet = IKEvRecv($if, $sec, 0, 1,
			@packets,
			@recv_packets_at_linkx);

		# save unexpect
		push @UNEXPECT, @{ $recv_packet{'SaUnexpect'} };

		# Delay HoT
		if ($hotis_flag == 1) {
			$hotis_flag = 2;
		}

		# Known Packet
		if ($recv_packet{ikeStatus} eq 'StUserFrame') {
			# set default process & global
			if ($recv_packet_process{$recv_packet{recvFrame}} ne undef) {
				$recv_process = $recv_packet_process{$recv_packet{recvFrame}};
				%{$recv_process->{store}} = %recv_packet;
			}

			# BINGO !!
			foreach $_ (@packets) {
				if ($recv_packet{recvFrame} eq $_) {
					return (%recv_packet);
				}
			}

			# Return Routability
			if ($recv_packet{recvFrame} eq 'hoti_nuthga_cn0ga_tnl_nutx_ha0') {
				if ($hotis_flag != 0) {
					$recv_process = $recv_packet_process{$hoti_packet{recvFrame}};
					&{$recv_process->{func}}($if, $recv_process->{msg}, \%hoti_packet);
					$hotis_flag = 0;
				}
				%hoti_packet = %recv_packet;
				$hotis_flag = 1;
			}
			elsif ($recv_packet{recvFrame} eq 'coti_nutxga_cn0ga') {
				$coti_flag ++;
				&{$recv_process->{func}}($if, $recv_process->{msg}, \%recv_packet);
			}
			# Default Reply
			else {
				# default process
				&{$recv_process->{func}}($if, $recv_process->{msg}, \%recv_packet);
			}

			# close to sending time of target
			$now_time = $recv_packet{recvTime1};

			# for return at timeout
			$recv_packet{status} = 2;
		}
		# IKE event
		elsif ($recv_packet{ikeStatus} eq 'StCallBack') {
			# for return at timeout
			$recv_packet{status} = 2;
			return (%recv_packet);
		}
		# Timeout
		elsif ($recv_packet{ikeStatus} eq 'StTimeOut') {
			# close to sending time of target
			$now_time += $sec;
			if ($sec >= $MinDelayBetweenRAs) {
				$ra_flag = 1;
			}

			# for return at timeout
			$recv_packet{recvTime1} = $now_time;
		}
#		# Unexpect Packet
#		elsif ($recv_packet{status} == 2) {
#			# close to sending time of target
#			$now_time = $recv_packet{recvTime1};
#
#			# check unexpect at the end
#			$recv_packet{'vRecvPKT'} = $V6evalTool::vRecvPKT;
#			push @UNEXPECT, { %recv_packet };
#		}
		# Internal Error
		else {
			vLogHTML_Fail("vRecv internal error.");
			exit $V6evalTool::exitFatal;
		}

		# Delay HoT
		if ($hotis_flag == 2) {
			$recv_process = $recv_packet_process{$hoti_packet{recvFrame}};
			&{$recv_process->{func}}($if, $recv_process->{msg}, \%hoti_packet);
			$hotis_flag = 0;
		}

		# Unsol RA
		if ($ra_flag == 0) {
			$wk = time;
			if ($wk >= ($SEND_PACKET_RA{sentTime1} + $MinDelayBetweenRAs)) {
				$ra_flag = 1;
			}
		}
		if ($ra_flag == 1) {
			if ($MN_CONF{SET_RA_RBIT} eq 'YES') {
				%SEND_PACKET_RA_LINKX = vSend_ra($if, 'ra_r1lla_allnodemcast_sll_r1_mtu_pfx_r1ga', 0);
			}
			else {
				%SEND_PACKET_RA_LINKX = vSend_ra($if, 'ra_r1lla_allnodemcast_sll_r1_mtu_pfx_linkx', 0);
			}
			$ra_flag = 0;
		}
	}

	# timeout
	return (%recv_packet);
}

#-----------------------------------------------------------------------------#
# vRecv_at_LinkY($$@)
#-----------------------------------------------------------------------------#
sub vRecv_at_LinkY($$@) {
	my ($if, $timeout, @packets) = @_;
	my %recv_packet;
	my $recv_process;
	my $sec;
	my %hoti_packet;
	my $hoti_flag = 0;
	my $hotis_flag = 0;
	my $coti_flag = 0;
	my $ra_flag = 0;

	my %hot_packet;    # Mobile to Mobile
	my %cot_packet;    # Mobile to Mobile
	my $hots_flag = 0; # Mobile to Mobile
	my $hot_flag = 0;  # Mobile to Mobile
	my $cot_flag = 0;  # Mobile to Mobile

	# check new Link
	if (set_now_link("LinkY") == 1) {
		# First RA at Link0
		if ($MN_CONF{SET_RA_RBIT} eq 'YES') {
			%SEND_PACKET_RA_LINKY = vSend_ra($if, 'ra_r2lla_allnodemcast_sll_r2_mtu_pfx_r2ga', 0);
		}
		else {
			%SEND_PACKET_RA_LINKY = vSend_ra($if, 'ra_r2lla_allnodemcast_sll_r2_mtu_pfx_linky', 0);
		}
	}

	# dummy route for debug
	if ($MN_CONF{'ENV_IKE_WO_IKE'} == 1) {
		set_sa();
		if ($UP_SA_CHECKER ne '') {
			$recv_packet{status} = 2;
			return (%recv_packet);
		}
	}
	# end

	# Timer
	if ($timeout <= 0) {
		$timeout = 1;
	}
	my $now_time = time;
	my $end_time = $now_time + $timeout;

	# wait for expect packet or timeout
	while ($now_time < $end_time) {

		$sec = $end_time - $now_time;
		if ($sec > $IF0_Recvtime) {
			$sec = $IF0_Recvtime;
		}

		# Receive LinkY
		%recv_packet = IKEvRecv($if, $sec, 0, 1,
			@packets,
			@recv_packets_at_linky);

		# save unexpect
		push @UNEXPECT, @{ $recv_packet{'SaUnexpect'} };

		# Delay HoT
		if ($hotis_flag == 1) {
			$hotis_flag = 2;
		}

		# Known Packet
		if ($recv_packet{ikeStatus} eq 'StUserFrame') {
			# set default process & global
			if ($recv_packet_process{$recv_packet{recvFrame}} ne undef) {
				$recv_process = $recv_packet_process{$recv_packet{recvFrame}};
				%{$recv_process->{store}} = %recv_packet;
			}

			# BINGO !!
			foreach $_ (@packets) {
				if ($recv_packet{recvFrame} eq $_) {
					return (%recv_packet);
				}
			}

			# Return Routability - Correspondent Node behavior
			if ($recv_packet{recvFrame} eq 'hoti_nuthga_cn0ga_tnl_nuty_ha0') {
				if ($hotis_flag != 0) {
					$recv_process = $recv_packet_process{$hoti_packet{recvFrame}};
					&{$recv_process->{func}}($if, $recv_process->{msg}, \%hoti_packet);
					$hotis_flag = 0;
				}
				%hoti_packet = %recv_packet;
				$hotis_flag = 1;
			}
			elsif ($recv_packet{recvFrame} eq 'coti_nutyga_cn0ga') {
				$coti_flag ++;
				&{$recv_process->{func}}($if, $recv_process->{msg}, \%recv_packet);
			}
			# Default Reply
			else {
				# default process
				&{$recv_process->{func}}($if, $recv_process->{msg}, \%recv_packet);
			}

			# close to sending time of target
			$now_time = $recv_packet{recvTime1};

			# for return at timeout
			$recv_packet{status} = 2;
		}
		# IKE event
		elsif ($recv_packet{ikeStatus} eq 'StCallBack') {
			# for return at timeout
			$recv_packet{status} = 2;
			return (%recv_packet);
		}
		# Timeout
		elsif ($recv_packet{ikeStatus} eq 'StTimeOut') {
			# close to sending time of target
			$now_time += $sec;
			if ($sec >= $MinDelayBetweenRAs) {
				$ra_flag = 1;
			}

			# for return at timeout
			$recv_packet{recvTime1} = $now_time;
		}
#		# Unexpected Packet
#		elsif ($recv_packet{status} == 2) {
#			# close to sending time of target
#			$now_time = $recv_packet{recvTime1};
#
#			# check unexpect at the end
#			$recv_packet{'vRecvPKT'} = $V6evalTool::vRecvPKT;
#			push @UNEXPECT, { %recv_packet };
#		}
		# Internal Error
		else {
			vLogHTML_Fail("vRecv internal error.");
			exit $V6evalTool::exitFatal;
		}

		# Delay HoT
		if ($hotis_flag == 2) {
			$recv_process = $recv_packet_process{$hoti_packet{recvFrame}};
			&{$recv_process->{func}}($if, $recv_process->{msg}, \%hoti_packet);
			$hotis_flag = 0;
		}

		# Unsol RA
		if ($ra_flag == 0) {
			$wk = time;
			if ($wk >= ($SEND_PACKET_RA{sentTime1} + $MinDelayBetweenRAs)) {
				$ra_flag = 1;
			}
		}
		if ($ra_flag == 1) {
			if ($MN_CONF{SET_RA_RBIT} eq 'YES') {
				%SEND_PACKET_RA_LINKY = vSend_ra($if, 'ra_r2lla_allnodemcast_sll_r2_mtu_pfx_r2ga', 0);
			}
			else {
				%SEND_PACKET_RA_LINKY = vSend_ra($if, 'ra_r2lla_allnodemcast_sll_r2_mtu_pfx_linky', 0);
			}
			$ra_flag = 0;
		}
	}

	# timeout
	return (%recv_packet);
}

#-----------------------------------------------------------------------------#
# vRecv_at_Link0_return($$@)
#-----------------------------------------------------------------------------#
sub vRecv_at_Link0_return($$@) {
	my ($if, $timeout, @packets) = @_;
	my %recv_packet;
	my $recv_process;
	my $sec;
	my $ra_flag = 0;

	# Real Home Link
	if ($MN_CONF{TEST_FUNC_REAL_HOME_LINK} ne 'YES') {
		$packet{status} = 0;
		return (%packet);
	}

	# check new Link
	if (set_now_link("Link0") == 1) {
		# First RA at Link0
		%SEND_PACKET_RA_LINK0 = vSend_ra($if, 'ra_ha0lla_allnodemcast_sll_ha0_mtu_pfx_ha0ga_hainfo', 0);
	}

	# dummy route for debug
	if ($MN_CONF{'ENV_IKE_WO_IKE'} == 1) {
		set_sa();
		if ($UP_SA_CHECKER ne '') {
			$recv_packet{status} = 2;
			return (%recv_packet);
		}
	}
	# end

	# Timer
	if ($timeout <= 0) {
		$timeout = 1;
	}
	my $now_time = time;
	my $end_time = $now_time + $timeout;

	# wait for expect packet or timeout
	while ($now_time < $end_time) {

		$sec = $end_time - $now_time;
		if ($sec > $IF0_Recvtime) {
			$sec = $IF0_Recvtime;
		}

		# Receive Link0
		%recv_packet = IKEvRecv($if, $sec, 0, 1,
			@packets,
			@recv_packets_at_link0_return);

		# save unexpect
		push @UNEXPECT, @{ $recv_packet{'SaUnexpect'} };

		# Known Packet
		if ($recv_packet{ikeStatus} eq 'StUserFrame') {
			# set default process & global
			if ($recv_packet_process{$recv_packet{recvFrame}} ne undef) {
				$recv_process = $recv_packet_process{$recv_packet{recvFrame}};
				%{$recv_process->{store}} = %recv_packet;
			}

			# BINGO !!
			foreach $_ (@packets) {
				if ($recv_packet{recvFrame} eq $_) {
					return (%recv_packet);
				}
			}

			# default process
			&{$recv_process->{func}}($if, $recv_process->{msg}, \%recv_packet);

			# close to sending time of target
			$now_time = $recv_packet{recvTime1};

			# for return at timeout
			$recv_packet{status} = 2;
		}
		# IKE event
		elsif ($recv_packet{ikeStatus} eq 'StCallBack') {
			# for return at timeout
			$recv_packet{status} = 2;
			return (%recv_packet);
		}
		# Timeout
		elsif ($recv_packet{ikeStatus} eq 'StTimeOut') {
			# close to sending time of target
			$now_time += $sec;
			if ($sec >= $MinDelayBetweenRAs) {
				$ra_flag = 1;
			}

			# for return at timeout
			$recv_packet{recvTime1} = $now_time;
		}
#		# Unexpect Packet
#		elsif ($recv_packet{status} == 2) {
#			# close to sending time of target
#			$now_time = $recv_packet{recvTime1};
#
#			# check unexpect at the end
#			$recv_packet{'vRecvPKT'} = $V6evalTool::vRecvPKT;
#			push @UNEXPECT, { %recv_packet };
#		}
		# Internal Error
		else {
			vLogHTML_Fail("vRecv internal error.");
			exit $V6evalTool::exitFatal;
		}

		# Unsol RA
		if ($ra_flag == 0) {
			$wk = time;
			if ($wk >= ($SEND_PACKET_RA{sentTime1} + $MinDelayBetweenRAs)) {
				$ra_flag = 1;
			}
		}
		if ($ra_flag == 1) {
			%SEND_PACKET_RA_LINK0 = vSend_ra($if, 'ra_ha0lla_allnodemcast_sll_ha0_mtu_pfx_ha0ga_hainfo', 0);
			$ra_flag = 0;
		}
	}

	# timeout
	return (%recv_packet);
}

#-----------------------------------------------------------------------------#
# vRecv_to_establish_SA_at_LinkX($$)
#-----------------------------------------------------------------------------#
sub vRecv_to_establish_SA_at_LinkX($$) {
	my ($if, $sa) = @_;

	if ($MN_CONF{TEST_FUNC_IKE} eq 'YES') {
		if (check_sa($sa) == 1) {

			# wait for establishing of IPsec SA
			$UP_SA_CHECKER = $sa;
			vRecv_at_LinkX($if, $MN_CONF{'FUNC_DETAIL_IKE_TIME'});
			$UP_SA_CHECKER = '';
			if (check_sa($sa) == 1) {
				vLogHTML_Fail("FAIL: SA is not establish. $MN_CONF{FUNC_DETAIL_IKE_TIME}[sec]");
				return (-1);
			}
		}
	}

	return (0);
}

#-----------------------------------------------------------------------------#
# vRecv_to_establish_all_SA_at_LinkX($)
#-----------------------------------------------------------------------------#
sub vRecv_to_establish_all_SA_at_LinkX($) {
	my ($if) = @_;

	if ($MN_CONF{TEST_FUNC_IKE} eq 'YES') {
		vLogHTML_Fail("vRecv_to_establish_all_SA_at_LinkX: SA_SET_FLAG=$SA_SET_FLAG");
		if ($SA_SET_FLAG == 0) {
			# wait for establishing of all IPsec SAs
			$UP_SA_CHECKER = 'ALL';
			vRecv_at_LinkX($if, $MN_CONF{'FUNC_DETAIL_IKE_TIME'});
			$UP_SA_CHECKER = '';

			if ($SA_SET_FLAG == 0) {
				vLogHTML_Fail("FAIL: All SA were not established. $MN_CONF{FUNC_DETAIL_IKE_TIME} [sec]");
				return (-1);
			}
		}
	}

	return (0);
}

#-----------------------------------------------------------------------------#
# vRecv_to_detect_movement_at_LinkX($$)
#-----------------------------------------------------------------------------#
sub vRecv_to_detect_movement_at_LinkX($$) {
	my ($if, $timeout) = @_;
	my %packet_bu;

	# for IKEv1
	if (vRecv_to_establish_SA_at_LinkX($if, 'sa12_ha0') != 0) {
		$packet_bu{status} = 2;
		return (%packet_bu);
	}

	#--------------------------------------------------------------#
	# NUT moves to LinkX.
	#--------------------------------------------------------------#
	# Receive Binding Update to HA0. (NUTX -> HA0)
	%packet_bu = vRecv_at_LinkX($if, $timeout, 'bu_nutxga_ha0ga_hoa_nuthga');
	if ($packet_bu{status} != 0) {
		vLogHTML_Fail("HA0 does not receive Binding Update. $timeout [sec]");
	}

	return (%packet_bu);
}

#-----------------------------------------------------------------------------#
# vRecv_to_detect_movement_at_LinkY($$)
#-----------------------------------------------------------------------------#
sub vRecv_to_detect_movement_at_LinkY($$) {
	my ($if, $timeout) = @_;

	#--------------------------------------------------------------#
	# NUT moves to LinkY.
	#--------------------------------------------------------------#
	# Receive Binding Update. (NUTY -> HA0)
	my %packet_bu = vRecv_at_LinkY($if, $timeout, 'bu_nutyga_ha0ga_hoa_nuthga');
	if ($packet_bu{status} != 0) {
		vLogHTML_Fail("HA0 does not receive Binding Update. $timeout [sec]");
	}

	return (%packet_bu);
}

#-----------------------------------------------------------------------------#
# vRecv_to_detect_movement_at_Link0($$)
#-----------------------------------------------------------------------------#
sub vRecv_to_detect_movement_at_Link0($$) {
	my ($if, $timeout) = @_;
	my $sec;

	# Real Home Link
	if ($MN_CONF{TEST_FUNC_REAL_HOME_LINK} ne 'YES') {
		$packet{status} = 0;
		return (%packet);
	}

	my %value_bu = get_value_of_bu(0, \%RECV_PACKET_BU);
	#--------------------------------------------------------------#
	# NUT moves to Link0.
	#--------------------------------------------------------------#
	my $now_time = time;
	my $end_time = $now_time + $timeout;
	while ($now_time < $end_time) {

		$sec = $end_time - $now_time;
		%packet = vRecv_at_Link0_return($if, $sec,
			@recv_packets_at_link0_detect
			);
		$now_time = time;

		if (($packet{recvFrame} eq 'bu_nuthga_ha0ga') ||
		    ($packet{recvFrame} eq 'bu_nuthga_ha0ga_hoa_nuthga')) {
			%packet_bu = %packet;
			last;
		}
		elsif (($packet{recvFrame} eq 'hoti_nuthga_cn0ga') ||
		       ($packet{recvFrame} eq 'hoti_nuthga_cn0ga_tnl_nuth_ha0') ||
		       ($packet{recvFrame} eq 'coti_nuthga_cn0ga') ||
		       ($packet{recvFrame} eq 'bu_nuthga_cn0ga') ||
		       ($packet{recvFrame} eq 'bu_nuthga_cn0ga_hoa_nuthga')) {
			vLogHTML_Fail("NUT sends Correspondent De-Registration before the Home De-Registration.");
			last;
		}
		elsif ($packet{status} == 0) {
			%value_addr = get_value_of_ipv6(0, \%packet);
			%saddr_tbl = get_addr_tbl($value_addr{SourceAddress});
			if ($saddr_tbl{node_name} =~ /nuth/) {
				vLogHTML_Fail("NUT use Home Address before Home De-Registration.");
				last;
			}
			if (($packet{recvFrame} eq 'ns_any_any') ||
			    ($packet{recvFrame} eq 'ns_any_any_w_ipsec') ||
			    ($packet{recvFrame} eq 'ns_any_any_opt_any') ||
			    ($packet{recvFrame} eq 'ns_any_any_opt_any_w_ipsec')) {

				$rtn = check_ns(1, \%packet);
				if ($rtn == 0) {
					vSend_na2($if, \%packet);
				}
				elsif ($rtn == 1) {
					%value_dad = get_value_of_ns(0, \%packet);
					if ($value_dad{TargetAddress} eq $node_hash{nuth_ga}) {
						vSend_na($if, 'na_ha0lla_alnodemcast_tgt_nuthga_tll_ha0', $packet);
					}
					elsif ($value_dad{TargetAddress} eq $node_hash{nuth_lla}) {
						if ($value_bu{LFlag} == 1) {
							vSend_na($if, 'na_ha0lla_alnodemcast_tgt_nuthlla_tll_ha0', $packet);
						}
						else {
							vLogHTML_Info("    no-reply");
						}
					}
					else {
						vLogHTML_Info("    no-reply");
					}
				}
				else {
					vLogHTML_Info("    no-reply");
				}
			}
			elsif (($packet{recvFrame} eq 'rs_any_any') ||
			       ($packet{recvFrame} eq 'rs_any_any_opt_any')) {
				vReply_rs($if, 0, \%packet, 0);
			}
			elsif (($packet{recvFrame} eq 'na_any_any') ||
			       ($packet{recvFrame} eq 'na_any_any_opt_any')) {
				vReply_na($if, 0, \%packet, 0);
			}
			elsif (($packet{recvFrame} eq 'ra_any_any') ||
			       ($packet{recvFrame} eq 'ra_any_any_opt_any')) {
				vReply_ra($if, 0, \%packet, 0);
			}
		}
	}

	if (%packet_bu == 0) {
		vLogHTML_Fail("HA0 does not receive Binding Update. $timeout [sec]");
		$packet_bu{status} = 2;
	}

	return (%packet_bu);
}

#-----------------------------------------------------------------------------#
# vRecv_to_move_from_Link0_to_LinkX($)
#-----------------------------------------------------------------------------#
sub vRecv_to_move_from_Link0_to_LinkX($) {
	my ($if) = @_;
	my @value = ();

	#--------------------------------------------------------------#
	# NUT starts at Link0.
	#--------------------------------------------------------------#
	# Send Router Advertisement. (HA0 -> HA0_allnode_multi)
	vRecv_at_Link0($if, $FIRST_RA_TIME);

	#--------------------------------------------------------------#
	# NUT moves from Link0 to LinkX.
	#--------------------------------------------------------------#
	my %packet = vRecv_to_detect_movement_at_LinkX($if, $BU_TIME);
	if ($packet{status} != 0) {
		return (%packet);
	}

	# Send Binding Acknowledgement. (HA0 -> NUTX)
	vSend_ba($if, 'ba_ha0ga_nutxga_rh2_nuthga', \%RECV_PACKET_BU);

	return (%packet);
}

#-----------------------------------------------------------------------------#
# vRecv_to_move_from_Link0_to_LinkX_NonHA($)
#-----------------------------------------------------------------------------#
sub vRecv_to_move_from_Link0_to_LinkX_NonHA($) {
	my ($if) = @_;
	my @value = ();

	#--------------------------------------------------------------#
	# NUT starts at Link0.
	#--------------------------------------------------------------#
	# Send Router Advertisement. (HA0 -> HA0_allnode_multi)
	vRecv_at_Link0_NonHA($if, $FIRST_RA_TIME);

	#--------------------------------------------------------------#
	# NUT0 moves from Link0 to LinkX
	#--------------------------------------------------------------#
	my %packet = vRecv_to_detect_movement_at_LinkX($if, $BU_TIME);
	if ($packet{status} != 0) {
		return (%packet);
	}

	# Send Binding Acknowledgement. (HA0 -> NUTX)
	vSend_ba($if, 'ba_ha0ga_nutxga_rh2_nuthga', \%RECV_PACKET_BU);

	return (%packet);
}

#-----------------------------------------------------------------------------#
# vRecv_to_move_from_Link0_to_LinkX_w_all_SA($)
#-----------------------------------------------------------------------------#
sub vRecv_to_move_from_Link0_to_LinkX_w_all_SA($) {
	my ($if) = @_;
	my @value = ();

	#--------------------------------------------------------------#
	# NUT moves from Link0 to LinkX.
	#--------------------------------------------------------------#
	my %packet = vRecv_to_move_from_Link0_to_LinkX($if);
	if ($packet{status} != 0) {
		return (%packet);
	}

	if (vRecv_to_establish_all_SA_at_LinkX($if) != 0) {
		$packet{status} = 2;
	}

	return (%packet);
}

#-----------------------------------------------------------------------------#
# vRecv_to_move_from_LinkX_to_LinkY($)
#-----------------------------------------------------------------------------#
sub vRecv_to_move_from_LinkX_to_LinkY($) {
	my ($if) = @_;
	my @value = ();

	#--------------------------------------------------------------#
	# NUT stays at LinkX.
	#--------------------------------------------------------------#
	# Send Router Advertisement. (R1 -> R1_allnode_multi)
	vRecv_at_LinkX($if, $MinDelayBetweenRAs);

	#--------------------------------------------------------------#
	# NUTX moves from LinkX to LinkY.
	#--------------------------------------------------------------#
	my %packet = vRecv_to_detect_movement_at_LinkY($if, $BU_TIME);
	if ($packet{status} != 0) {
		return (%packet);
	}

	# Send Binding Acknowledgement. (HA0 -> NUTY)
	vSend_ba($if, 'ba_ha0ga_nutyga_rh2_nuthga', \%RECV_PACKET_BU);

	return (%packet);
}

#-----------------------------------------------------------------------------#
# vRecv_to_move_from_LinkX_to_Link0($)
#-----------------------------------------------------------------------------#
sub vRecv_to_move_from_LinkX_to_Link0($) {
	my ($if) = @_;
	my @value = ();

	# Real Home Link
	if ($MN_CONF{TEST_FUNC_REAL_HOME_LINK} ne 'YES') {
		$packet{status} = 0;
		return (%packet);
	}

	#--------------------------------------------------------------#
	# NUT stays at LinkX.
	#--------------------------------------------------------------#
	# Send Router Advertisement. (R1 -> R1_allnode_multi)
	vRecv_at_LinkX($if, $MinDelayBetweenRAs);
	%packet_pre_bu = %RECV_PACKET_BU;

	#--------------------------------------------------------------#
	# NUTX moves from LinkX to Link0.
	#--------------------------------------------------------------#
	my %packet = vRecv_to_detect_movement_at_Link0($if, $BU_TIME);
	if ($packet{status} != 0) {
		return (%packet);
	}

	# Send Binding Acknowledgement. (HA0 -> NUT0)
	vSend_ba($if, 'ba_ha0ga_nuthga', \%RECV_PACKET_BU);

	# Receive Neighbor Advertisement. (NUT0 -> NUT0_allnode_multi)
	my %value_pre_bu = get_value_of_bu(0, \%packet_pre_bu);
	my $na_lla_flag = 0;
	my $na_ga_flag = 0;
	my $now_time = time;
	my $end_time = $now_time + $BU_TIME;
	while ($now_time < $end_time) {

		$sec = $end_time - $now_time;
		%packet = vRecv_at_Link0_return($if, $sec,
			@recv_packets_at_link0_move
			);
		$now_time = time;

		if (($packet{recvFrame} eq 'bu_nuthga_ha0ga') ||
		    ($packet{recvFrame} eq 'bu_nuthga_ha0ga_hoa_nuthga')) {
			@value = ('BA_Status', '133');
			vSend_ba($if, 'ba_ha0ga_nuthga', \%packet, @value);
		}
		elsif (($packet{recvFrame} eq 'na_any_any') ||
		       ($packet{recvFrame} eq 'na_any_any_opt_any')) {

			vReply_na($if, 0, \%packet, 0);

			%value_na_addr = get_value_of_ipv6(0, \%packet);
			%value_na = get_value_of_na(0, \%packet);
			while (1) {
				# check
				if ($value_na_addr{DestinationAddress} ne $node_hash{all_node_multi}) {
					last;
				}
				if ($value_na{SFlag} == 1) {
					last;
				}
				if ($value_na{OFlag} == 0) {
					last;
				}
				if ($value_na{TargetAddress} eq $node_hash{nuth_ga}) {
					$na_ga_flag = 1;
				}
				elsif ($value_na{TargetAddress} eq $node_hash{nuth_lla}) {
					$na_lla_flag = 1;
				}
				last;
			}
			if ($na_ga_flag == 1 &&
			    ($na_lla_flag == 1 || $value_pre_bu{LFlag} == 0)) {
				last;
			}
		}
	}

	$packet{status} = 0;
	if ($na_ga_flag == 0) {
		vLogHTML_Fail("HA0 does not receive Neighbor Advertisement(Target Global).");
		$packet{status} = 2;
	}
	if ($na_lla_flag == 0) {
		if ($value_pre_bu{LFlag} == 1) {
			vLogHTML_Fail("HA0 does not receive Neighbor Advertisement(Target Link-Local). Though (L) bit in Binding Update is ON.");
			$packet{status} = 2;
		}
	}
	else {
		if ($value_pre_bu{LFlag} == 0) {
			vLogHTML_Fail("HA0 receives Neighbor Advertisement(Target Link-Local). Though (L) bit in Binding Update is OFF.");
			$packet{status} = 2;
		}
	}

	return (%packet);
}

#-----------------------------------------------------------------------------#
# vRecv_to_move_from_LinkY_to_Link0($)
#-----------------------------------------------------------------------------#
sub vRecv_to_move_from_LinkY_to_Link0($) {
	my ($if) = @_;
	my @value = ();

	# Real Home Link
	if ($MN_CONF{TEST_FUNC_REAL_HOME_LINK} ne 'YES') {
		$packet{status} = 0;
		return (%packet);
	}

	#--------------------------------------------------------------#
	# NUT stays at LinkY.
	#--------------------------------------------------------------#
	# Send Router Advertisement. (R2 -> R2_allnode_multi)
	vRecv_at_LinkY($if, $MinDelayBetweenRAs);
	%packet_pre_bu = %RECV_PACKET_BU;

	#--------------------------------------------------------------#
	# NUTY moves from LinkY to Link0.
	#--------------------------------------------------------------#
	my %packet = vRecv_to_detect_movement_at_Link0($if, $BU_TIME);
	if ($packet{status} != 0) {
		return (%packet);
	}

	# Send Binding Acknowledgement. (HA0 -> NUT0)
	vSend_ba($if, 'ba_ha0ga_nuthga', \%RECV_PACKET_BU);

	# Receive Neighbor Advertisement. (NUT0 -> NUT0_allnode_multi)
	my %value_pre_bu = get_value_of_bu(0, \%packet_pre_bu);
	my $na_lla_flag = 0;
	my $na_ga_flag = 0;
	my $now_time = time;
	my $end_time = $now_time + $BU_TIME;
	while ($now_time < $end_time) {

		$sec = $end_time - $now_time;
		%packet = vRecv_at_Link0_return($if, $sec,
			@recv_packets_at_link0_move
			);
		$now_time = time;

		if (($packet{recvFrame} eq 'bu_nuthga_ha0ga') ||
		    ($packet{recvFrame} eq 'bu_nuthga_ha0ga_hoa_nuthga')) {
			@value = ('BA_Status', '133');
			vSend_ba($if, 'ba_ha0ga_nuthga', \%packet, @value);
		}
		elsif (($packet{recvFrame} eq 'na_any_any') ||
		       ($packet{recvFrame} eq 'na_any_any_opt_any')) {

			vReply_na($if, 0, \%packet, 0);

			%value_na_addr = get_value_of_ipv6(0, \%packet);
			%value_na = get_value_of_na(0, \%packet);
			while (1) {
				# check
				if ($value_na_addr{DestinationAddress} ne $node_hash{all_node_multi}) {
					last;
				}
				if ($value_na{SFlag} == 1) {
					last;
				}
				if ($value_na{OFlag} == 0) {
					last;
				}
				if ($value_na{TargetAddress} eq $node_hash{nuth_ga}) {
					$na_ga_flag = 1;
				}
				elsif ($value_na{TargetAddress} eq $node_hash{nuth_lla}) {
					$na_lla_flag = 1;
				}
				last;
			}
			if ($na_ga_flag == 1 &&
			    ($na_lla_flag == 1 || $value_pre_bu{LFlag} == 0)) {
				last;
			}
		}
	}

	$packet{status} = 0;
	if ($na_ga_flag == 0) {
		vLogHTML_Fail("HA0 does not receive Neighbor Advertisement(Target Global).");
		$packet{status} = 2;
	}
	if ($na_lla_flag == 0) {
		if ($value_pre_bu{LFlag} == 1) {
			vLogHTML_Fail("HA0 does not receive Neighbor Advertisement(Target Link-Local). Though (L) bit in Binding Update is ON.");
			$packet{status} = 2;
		}
	}
	else {
		if ($value_pre_bu{LFlag} == 0) {
			vLogHTML_Fail("HA0 receives Neighbor Advertisement(Target Link-Local). Though (L) bit in Binding Update is OFF.");
			$packet{status} = 2;
		}
	}

	return (%packet);
}

#-----------------------------------------------------------------------------#
# CorrespondentRegistration_to_mn_at_LinkX($$$$)
#-----------------------------------------------------------------------------#
sub CorrespondentRegistration_to_mn_at_LinkX($$$$) {
	my ($if, $timeout, $lifetime, $coa) = @_;
	my %recv_packet;
	my %packet_hoti;
	my %packet_coti;
	my %packet_bu_cn;
	my @value = ();

	my $hot_flag = 0;
	my $cot_flag = 0;
	my $now_time = time;
	my $while_time = $now_time + $MAX_BINDACK_TIMEOUT;
	my $hot_trans_interval = $INITIAL_BINDACK_TIMEOUT;
	my $cot_trans_interval = $INITIAL_BINDACK_TIMEOUT;

	# CN Send BU CoTI and HoTI Message from MN
	@value = ('HOTI_HOTCOOKIE', "\\\"0123456789abcdef\\\"");
	%packet_hoti = vSend_hoti($if, 'hoti_cn0ga_nuthga_tnl_ha0_nutx', 0, @value);
	# MN not send CoTI when lifetime=0 is De-Registration
	if ($lifetime != 0) {
		@value = ('COTI_COTCOOKIE', "\\\"0123456789abcdef\\\"");
		%packet_hoti = vSend_coti($if, 'coti_cn0yga_nuthga_tnl_ha0_nutx', 0, @value);
	}
	else {
		$cot_flag = 1;
		$value_cot_to_cn{Index} = 0;
	}

	# Retranslation process
	while ($now_time < $while_time) {

		if (($hot_flag == 0) && ($cot_flag == 0)) {
			# CN Receive HoT and CoT Message from MN
			%recv_packet = vRecv_at_LinkX($if, $hot_trans_interval, 
				'hot_nuthga_cn0ga_tnl_nutx_ha0',
				'cot_nuthga_cn0yga_tnl_nutx_ha0',
				'hot_nutany_cn0ga_hoa_nuthga',
				'hot_nutany_cn0ga_hoa_nuthga_tnl_nutany_ha0',
				'hot_nutany_cn0yga',
				'cot_nutany_cn0yga',
				'cot_nutany_cn0yga_hoa_nuthga',
				'cot_nutany_cn0yga_hoa_nuthga_tnl_nutany_ha0');
		}
		elsif ($hot_flag == 0) {
			# CN Receive HoT Message from MN
			%recv_packet = vRecv_at_LinkX($if, $hot_trans_interval,
				'hot_nuthga_cn0ga_tnl_nutx_ha0',
				'hot_nutany_cn0ga_hoa_nuthga',
				'hot_nutany_cn0yga',
				'hot_nutany_cn0ga_hoa_nuthga_tnl_nutany_ha0');
		}
		else {
			# CN Receive CoT Message from MN
			%recv_packet = vRecv_at_LinkX($if, $cot_trans_interval,
				'cot_nuthga_cn0yga_tnl_nutx_ha0',
				'cot_nutany_cn0yga',
				'cot_nutany_cn0yga_hoa_nuthga',
				'cot_nutany_cn0yga_hoa_nuthga_tnl_nutany_ha0');
		}

		# Receive message selection
		if ($recv_packet{recvFrame} eq 'hot_nuthga_cn0ga_tnl_nutx_ha0') {
			# CN Receive Home Test
			%value_hot_to_cn = get_value_of_hot(0, \%recv_packet);
			$hot_flag = 1;
		}
		elsif ($recv_packet{recvFrame} eq 'cot_nuthga_cn0yga_tnl_nutx_ha0') {
			# CN Receive Care-of Test
			%value_cot_to_cn = get_value_of_cot(0, \%recv_packet);
			$cot_flag = 1;
		}
		elsif ($recv_packet{status} == 0) {
			vLogHTML_Info("CN0 receives Home Test(illegal) or Care-of Test(illegal).");
			$recv_packet{status} = 2;
			return (%recv_packet);
		}
		else {
			# the retransmission of HOTI or COTI is to 3 times.
			# (1:$INITIAL_BINDACK_TIMEOUT, 2:$INITIAL_BINDACK_TIMEOUT*2, 3:$INITIAL_BINDACK_TIMEOUT*4)
			if ($hot_flag == 0) {
				if ($hot_trans_interval <= ($PREFIX_ADV_TIMEOUT * 4)) {
					$wk = time;
					if ($hot_trans_interval <= ($wk - $packet_hoti{sentTime1})) {
						vLogHTML_Info("CN0 does not receive Home Test. Retransmit interval = $hot_trans_interval [sec]");
						@value = ('HOTI_HOTCOOKIE', "\\\"0123456789abcdef\\\"");
						%packet_hoti = vSend_hoti($if, 'hoti_cn0ga_nuthga_tnl_ha0_nutx', 0, @value);
						$hot_trans_interval = $hot_trans_interval * 2;
					}
				}
				else {
					# retransmission fail
					vLogHTML_Info("CN0 does not receive Home Test.");
					$packet_bu_cn{status} = 2;
					return (%packet_bu_cn);
				}
			}
			if ($cot_flag == 0) {
				if ($cot_trans_interval <= ($PREFIX_ADV_TIMEOUT * 4)) {
					$wk = time;
					if ($cot_trans_interval <= ($wk - $packet_coti{sentTime1})) {
						vLogHTML_Info("CN0 does not receive Care-of Test. Retransmit interval = $cot_trans_interval [sec]");
						@value = ('COTI_COTCOOKIE', "\\\"0123456789abcdef\\\"");
						%packet_coti = vSend_hoti($if, 'coti_cn0yga_nuthga_tnl_ha0_nutx', 0, @value);
						$cot_trans_interval = $cot_trans_interval * 2;
					}
				}
				else {
					# retransmission fail
					vLogHTML_Info("CN0 does not receive Care-of Test.");
					$packet_bu_cn{status} = 2;
					return (%packet_bu_cn);
				}
			}
		}
		if (($hot_flag == 1) && ($cot_flag == 1)) {
			last;
		}
	}

	# CN Send BU Message to MN
	$seq = get_sequence();
	if ($lifetime > 420) {
		$lifetime = 420;
	}
	$life = int($lifetime / 4);
	@value = (
		'BU_Reserved1', 0,
		'BU_Seqence', $seq,
		'BU_Aflag1', 1,
		'BU_Hflag', 0,
		'BU_Lflag', 0,
		'BU_Kflag', 0,
		'BU_Reserved2', 0,
		'BU_Lifetime', $life,
		'BU_HO_NONCE_INDEX', $value_hot_to_cn{Index},
		'BU_CO_NONCE_INDEX', $value_cot_to_cn{Index},
		'BU_TO_NUT_HOCOOKIE', "\\\"$value_hot_to_cn{KeygenToken}\\\"",
		'BU_TO_NUT_COCOOKIE', "\\\"$value_cot_to_cn{KeygenToken}\\\""
		);
	if ($lifetime != 0) {
		%packet_bu_cn = vSend_bu_cn($if, 'bu_cn0yga_nuthga_hoa_cn0ga_coa_cn0yga_tnl_ha0_nutx', 0, @value);
	}
	else {
		%packet_bu_cn = vSend_bu_cn($if, 'bu_cn0yga_nuthga_hoa_cn0ga_coa_cn0ga_del_tnl_ha0_nutx', 0, @value);
	}
	if ($MN_CONF{ENV_DEBUG} > 0) {
		get_value_of_bu_cn(1, \%packet_bu_cn);
	}
	return (%packet_bu_cn);
}

#-----------------------------------------------------------------------------#
# CorrespondentRegistration_to_mn_at_LinkY($$$$)
#-----------------------------------------------------------------------------#
sub CorrespondentRegistration_to_mn_at_LinkY($$$$) {
	my ($if, $timeout, $lifetime, $coa) = @_;
	my %recv_packet;
	my %packet_hoti;
	my %packet_coti;
	my %packet_bu_cn;
	my @value = ();

	my $hot_flag = 0;
	my $cot_flag = 0;
	my $now_time = time;
	my $while_time = $now_time + $MAX_BINDACK_TIMEOUT;
	my $hot_trans_interval = $INITIAL_BINDACK_TIMEOUT;
	my $cot_trans_interval = $INITIAL_BINDACK_TIMEOUT;

	# CN Send BU CoTI and HoTI Message from MN
	@value = ('HOTI_HOTCOOKIE', "\\\"0123456789abcdef\\\"");
	%packet_hoti = vSend_hoti($if, 'hoti_cn0ga_nuthga_tnl_ha0_nuty', 0, @value);
	# MN not send CoTI when if lifetime=0 is De-Registration
	if ($lifetime != 0) {
		@value = ('COTI_COTCOOKIE', "\\\"0123456789abcdef\\\"");
		%packet_hoti = vSend_coti($if, 'coti_cn0yga_nuthga_tnl_ha0_nuty', 0, @value);
	}
	else {
		$cot_flag = 1;
		$value_cot_to_cn{Index} = 0;
	}

	# Retranslation process
	while ($now_time < $while_time) {

		if (($hot_flag == 0) && ($cot_flag == 0)) {
			# CN Receive HoT and CoT Message from MN
			%recv_packet = vRecv_at_LinkY($if, $hot_trans_interval, 
				'hot_nuthga_cn0ga_tnl_nuty_ha0',
				'cot_nuthga_cn0yga_tnl_nuty_ha0',
				'hot_nutany_cn0yga',
				'hot_nutany_cn0ga_hoa_nuthga',
				'hot_nutany_cn0ga_hoa_nuthga_tnl_nutany_ha0',
				'cot_nutany_cn0yga',
				'cot_nutany_cn0yga_hoa_nuthga',
				'cot_nutany_cn0yga_hoa_nuthga_tnl_nutany_ha0');
		}
		elsif ($hot_flag == 0) {
			# CN Receive HoT Message from MN
			%recv_packet = vRecv_at_LinkY($if, $hot_trans_interval,
				'hot_nuthga_cn0ga_tnl_nuty_ha0',
				'hot_nutany_cn0yga',
				'hot_nutany_cn0ga_hoa_nuthga',
				'hot_nutany_cn0ga_hoa_nuthga_tnl_nutany_ha0');
		}
		else {
			# CN Receive CoT Message from MN
			%recv_packet = vRecv_at_LinkY($if, $cot_trans_interval,
				'cot_nuthga_cn0yga_tnl_nuty_ha0',
				'cot_nutany_cn0yga',
				'cot_nutany_cn0yga_hoa_nuthga',
				'cot_nutany_cn0yga_hoa_nuthga_tnl_nutany_ha0');
		}

		# Receive message selection
		if ($recv_packet{recvFrame} eq 'hot_nuthga_cn0ga_tnl_nuty_ha0') {
			# CN Receive Home Test
			%value_hot_to_cn = get_value_of_hot(0, \%recv_packet);
			$hot_flag = 1;
		}
		elsif ($recv_packet{recvFrame} eq 'cot_nuthga_cn0yga_tnl_nuty_ha0') {
			# CN Receive Care-of Test
			%value_cot_to_cn = get_value_of_cot(0, \%recv_packet);
			$cot_flag = 1;
		}
		elsif ($recv_packet{status} == 0) {
			vLogHTML_Info("CN0 receives Home Test(illegal) or Care-of Test(illegal).");
			$recv_packet{status} = 2;
			return (%recv_packet);
		}
		else {
			# the retransmission of HOTI or COTI is to 3 times.
			# (1:$INITIAL_BINDACK_TIMEOUT, 2:$INITIAL_BINDACK_TIMEOUT*2, 3:$INITIAL_BINDACK_TIMEOUT*4)
			if ($hot_flag == 0) {
				if ($hot_trans_interval <= ($PREFIX_ADV_TIMEOUT * 4)) {
					$wk = time;
					if ($hot_trans_interval <= ($wk - $packet_hoti{sentTime1})) {
						vLogHTML_Info("CN0 does not receive Home Test. Retransmit interval = $hot_trans_interval [sec]");
						@value = ('HOTI_HOTCOOKIE', "\\\"0123456789abcdef\\\"");
						%packet_hoti = vSend_hoti($if, 'hoti_cn0ga_nuthga_tnl_ha0_nuty', 0, @value);
						$hot_trans_interval = $hot_trans_interval * 2;
					}
				}
				else {
					# retransmission fail
					vLogHTML_Info("CN0 does not receive Home Test.");
					$packet_bu_cn{status} = 2;
					return (%packet_bu_cn);
				}
			}
			if ($cot_flag == 0) {
				if ($cot_trans_interval <= ($PREFIX_ADV_TIMEOUT * 4)) {
					$wk = time;
					if ($cot_trans_interval <= ($wk - $packet_coti{sentTime1})) {
						vLogHTML_Info("CN0 does not receive Care-of Test. Retransmit interval = $cot_trans_interval [sec]");
						@value = ('COTI_COTCOOKIE', "\\\"0123456789abcdef\\\"");
						%packet_coti = vSend_hoti($if, 'coti_cn0yga_nuthga_tnl_ha0_nuty', 0, @value);
						$cot_trans_interval = $cot_trans_interval * 2;
					}
				}
				else {
					# retransmission fail
					vLogHTML_Info("CN0 does not receive Care-of Test.");
					$packet_bu_cn{status} = 2;
					return (%packet_bu_cn);
				}
			}
		}
		if (($hot_flag == 1) && ($cot_flag == 1)) {
			last;
		}
	}

	# CN Send BU Message to MN
	$seq = get_sequence();
	if ($lifetime > 420) {
		$lifetime = 420;
	}
	$life = int($lifetime / 4);
	@value = (
		'BU_Reserved1', 0,
		'BU_Seqence', $seq,
		'BU_Aflag1', 1,
		'BU_Hflag', 0,
		'BU_Lflag', 0,
		'BU_Kflag', 0,
		'BU_Reserved2', 0,
		'BU_Lifetime', $life,
		'BU_HO_NONCE_INDEX', $value_hot_to_cn{Index},
		'BU_CO_NONCE_INDEX', $value_cot_to_cn{Index},
		'BU_TO_NUT_HOCOOKIE', "\\\"$value_hot_to_cn{KeygenToken}\\\"",
		'BU_TO_NUT_COCOOKIE', "\\\"$value_cot_to_cn{KeygenToken}\\\""
		);
	if ($lifetime != 0) {
		%packet_bu_cn = vSend_bu_cn($if, 'bu_cn0yga_nuthga_hoa_cn0ga_coa_cn0yga_tnl_ha0_nuty', 0, @value);
	}
	else {
		%packet_bu_cn = vSend_bu_cn($if, 'bu_cn0yga_nuthga_hoa_cn0ga_coa_cn0ga_del_tnl_ha0_nuty', 0, @value);
	}
	if ($MN_CONF{ENV_DEBUG} > 0) {
		get_value_of_bu_cn(1, \%packet_bu_cn);
	}
	return (%packet_bu_cn);
}

#-----------------------------------------------------------------------------#
# set default packet
#-----------------------------------------------------------------------------#
sub set_default_recv_packet() {
	my @default_recv_packet;

	# The packet to specify and its order at Link0
	# reply
	@default_recv_packet = (
		# ns
		'ns_any_any',
		'ns_any_any_w_ipsec',
		'ns_any_any_opt_any',
		'ns_any_any_opt_any_w_ipsec',
		# rs
		'rs_any_any',
		'rs_any_any_opt_any',
	);
	if (($MN_CONF{'TEST_FUNC_DHAAD'} eq 'YES') &&
	    ($MN_CONF{'FUNC_DETAIL_DHAAD_ON_HOMELINK'} eq 'YES')) {
		push (@default_recv_packet,
			# haadrequest
			'haadrequest_nut0lla_link0haany',
			'haadrequest_nuthga_link0haany',
		);
	}
	# no reply
	push (@default_recv_packet,
		# na
		'na_any_any',
		'na_any_any_opt_any',
		# ra
		#'ra_any_any',
		#'ra_any_any_opt_any',
		# echoreply
		'echoreply_nuthga_cn0ga',
	);
	@recv_packets_at_link0 = @default_recv_packet;

	# The packet to specify and its order at Link0 NonHA
	# reply
	@default_recv_packet = (
		# ns
		'ns_any_any',
		'ns_any_any_w_ipsec',
		'ns_any_any_opt_any',
		'ns_any_any_opt_any_w_ipsec',
		# rs
		'rs_any_any',
		'rs_any_any_opt_any',
	);
	if ($MN_CONF{'TEST_FUNC_DHAAD'} eq 'YES') {
		push (@default_recv_packet,
			# haadrequest
			'haadrequest_nut0lla_link0haany',
			'haadrequest_nuthga_link0haany',
		);
	}
	# no reply
	push (@default_recv_packet,
		# na
		'na_any_any',
		'na_any_any_opt_any',
		# ra
		#'ra_any_any',
		#'ra_any_any_opt_any',
		# echoreply
		'echoreply_nuthga_cn0ga',
	);
	@recv_packets_at_link0_NonHA = @default_recv_packet;


	# The packet to specify and its order at LinkX
	# reply
	@default_recv_packet = (
		# bu
		'bu_nutxga_ha0ga_hoa_nuthga',
	);
	if ($MN_CONF{'TEST_FUNC_RR'} eq 'YES') {
		push (@default_recv_packet,
			# bu cn
			'bu_nutxga_cn0ga_hoa_nuthga',
			'bu_nutxga_cn0ga_hoa_nuthga_coa_nutx',
			# coti
			'coti_nutxga_cn0ga',
			# hoti
			'hoti_nuthga_cn0ga_tnl_nutx_ha0',
		);
	}
	if ($MN_CONF{'TEST_FUNC_MPD'} eq 'YES') {
		push (@default_recv_packet,
			# mps
			'mps_nutxga_ha0ga_hoa_nuthga',
		);
	}
	push (@default_recv_packet,
		# ns
		'ns_any_any',
		'ns_any_any_w_ipsec',
		'ns_any_any_opt_any',
		'ns_any_any_opt_any_w_ipsec',
		# rs
		'rs_any_any',
		'rs_any_any_opt_any',
	);
	if ($MN_CONF{'TEST_FUNC_DHAAD'} eq 'YES') {
		push (@default_recv_packet,
			# haadrequest
			'haadrequest_nutxga_link0haany',
		);
	}
	# no reply
	if ($MN_CONF{'TEST_FUNC_RR'} eq 'YES') {
		push (@default_recv_packet,
			# brr
			'brr_nuthga_cn0ga_tnl_nutx_ha0',
			# ba
			'ba_nuthga_cn0yga_rh2_cn0ga_tnl_nutx_ha0',
			# cot
			'cot_nuthga_cn0yga_tnl_nutx_ha0',
			# hot
			'hot_nuthga_cn0ga_tnl_nutx_ha0',
		);
	}
	push (@default_recv_packet,
		# na
		'na_any_any',
		'na_any_any_opt_any',
		# ra
		#'ra_any_any',
		#'ra_any_any_opt_any',
		# echoreply
		'echoreply_nutxga_cn0ga',
		'echoreply_nuthga_cn0ga_tnl_nutx_ha0',
	);
	if ($MN_CONF{'TEST_FUNC_RR'} eq 'YES') {
		push (@default_recv_packet,
			'echoreply_nutxga_cn0ga_hoa_nuthga',
			'echoreply_nuthga_cn0yga_rh2_cn0ga_tnl_nutany_ha0',
			'echoreply_nutxga_cn0yga_rh2_cn0ga_hoa_nuthga',
		);
	}
	@recv_packets_at_linkx = @default_recv_packet;


	# The packet to specify and its order at LinkY
	# reply
	@default_recv_packet = (
		# bu
		'bu_nutyga_ha0ga_hoa_nuthga',
	);
	if ($MN_CONF{'TEST_FUNC_RR'} eq 'YES') {
		push (@default_recv_packet,
			# bu cn
			'bu_nutyga_cn0ga_hoa_nuthga',
			'bu_nutyga_cn0ga_hoa_nuthga_coa_nuty',
			# coti
			'coti_nutyga_cn0ga',
			# hoti
			'hoti_nuthga_cn0ga_tnl_nuty_ha0',
		);
	}
	if ($MN_CONF{'TEST_FUNC_MPD'} eq 'YES') {
		push (@default_recv_packet,
			# mps
			'mps_nutyga_ha0ga_hoa_nuthga',
		);
	}
	push (@default_recv_packet,
		# ns
		'ns_any_any',
		'ns_any_any_w_ipsec',
		'ns_any_any_opt_any',
		'ns_any_any_opt_any_w_ipsec',
		# rs
		'rs_any_any',
		'rs_any_any_opt_any',
	);
	if ($MN_CONF{'TEST_FUNC_DHAAD'} eq 'YES') {
		push (@default_recv_packet,
			# haadrequest
			'haadrequest_nutyga_link0haany',
		);
	}
	# no reply
	if ($MN_CONF{'TEST_FUNC_RR'} eq 'YES') {
		push (@default_recv_packet,
			# brr
			'brr_nuthga_cn0ga_tnl_nuty_ha0',
			# ba
			'ba_nuthga_cn0yga_rh2_cn0ga_tnl_nuty_ha0',
			# cot
			'cot_nuthga_cn0yga_tnl_nuty_ha0',
			# hot
			'hot_nuthga_cn0ga_tnl_nuty_ha0',
		);
	}
	push (@default_recv_packet,
		# na
		'na_any_any',
		'na_any_any_opt_any',
		# ra
		#'ra_any_any',
		#'ra_any_any_opt_any',
		# echoreply
		'echoreply_nutyga_cn0ga',
		'echoreply_nuthga_cn0ga_tnl_nuty_ha0',
	);
	if ($MN_CONF{'TEST_FUNC_RR'} eq 'YES') {
		push (@default_recv_packet,
			'echoreply_nutyga_cn0ga_hoa_nuthga',
			'echoreply_nuthga_cn0yga_rh2_cn0ga_tnl_nutany_ha0',
			'echoreply_nutyga_cn0yga_rh2_cn0ga_hoa_nuthga',
		);
	}
	@recv_packets_at_linky = @default_recv_packet;

	# The packet to specify and its order at Link0 return
	# reply
	@default_recv_packet = (
		# bu
		'bu_nuthga_ha0ga',
		'bu_nuthga_ha0ga_hoa_nuthga',
	);
	if ($MN_CONF{'TEST_FUNC_RR'} eq 'YES') {
		push (@default_recv_packet,
			# bu cn
			'bu_nuthga_cn0ga',
			'bu_nuthga_cn0ga_hoa_nuthga',
			# hoti
			'hoti_nuthga_cn0ga',
			'hoti_nuthga_cn0ga_tnl_nuth_ha0',
		);
	}
	push (@default_recv_packet,
		# ns
		'ns_any_any',
		'ns_any_any_w_ipsec',
		'ns_any_any_opt_any',
		'ns_any_any_opt_any_w_ipsec',
		# rs
		'rs_any_any',
		'rs_any_any_opt_any',
	);
	if (($MN_CONF{'TEST_FUNC_DHAAD'} eq 'YES') &&
	    ($MN_CONF{'FUNC_DETAIL_DHAAD_ON_HOMELINK'} eq 'YES')) {
		push (@default_recv_packet,
			# haadrequest
			'haadrequest_nut0lla_link0haany',
			'haadrequest_nuthga_link0haany',
		);
	}
	# no reply
	push (@default_recv_packet,
		# na
		'na_any_any',
		'na_any_any_opt_any',
		# ra
		#'ra_any_any',
		#'ra_any_any_opt_any',
		# echoreply
		'echoreply_nuthga_cn0ga',
	);
	@recv_packets_at_link0_return = @default_recv_packet;

	# The packet to specify and its order at Link0 detect
	@default_recv_packet = (
			'bu_nuthga_ha0ga',
			'bu_nuthga_ha0ga_hoa_nuthga',
			'ns_any_any',
			'ns_any_any_w_ipsec',
			'ns_any_any_opt_any',
			'ns_any_any_opt_any_w_ipsec',
			'rs_any_any',
			'rs_any_any_opt_any',
			'na_any_any',
			'na_any_any_opt_any',
			'ra_any_any',
			'ra_any_any_opt_any',
	);
	if ($MN_CONF{'TEST_FUNC_RR'} eq 'YES') {
		push (@default_recv_packet,
			'hoti_nuthga_cn0ga',
			'hoti_nuthga_cn0ga_tnl_nuth_ha0',
			'coti_nuthga_cn0ga',
			'bu_nuthga_cn0ga',
			'bu_nuthga_cn0ga_hoa_nuthga',
		);
	}
	@recv_packets_at_link0_detect = @default_recv_packet;

	# The packet to specify and its order at Link0 move
	@default_recv_packet = (
			'bu_nuthga_ha0ga',
			'bu_nuthga_ha0ga_hoa_nuthga',
			'na_any_any',
			'na_any_any_opt_any',
	);
	if ($MN_CONF{'TEST_FUNC_RR'} eq 'YES') {
		push (@default_recv_packet,
			'hoti_nuthga_cn0ga',
			'hoti_nuthga_cn0ga_tnl_nuth_ha0',
			'coti_nuthga_cn0ga',
			'bu_nuthga_cn0ga',
			'bu_nuthga_cn0ga_hoa_nuthga',
		);
	}
	@recv_packets_at_link0_move = @default_recv_packet;

	return;
}

#-----------------------------------------------------------------------------#
# Init_MN(@)
#-----------------------------------------------------------------------------#
sub Init_MN(@) {
	my (@options) = @_;

	# Set the config parameter.
	set_config(0);

	# 
	display_config();

	# Do the test satisfied the condition.
	check_option(@options);

	# Initialize the state of TARGET.
	init_mn();

	# set default recv packet
	set_default_recv_packet();

	# Prefix Lifetime
	set_link_lifetime('Link0', $PREFIX_LIFETIME, $PREFIX_LIFETIME);
	%st_LinkX = %st_LinkY = %st_LinkZ = %st_Link0;

	# clean up packet definitions
	vCPP('');

	# dummy route for debug
	if ($MN_CONF{'ENV_IKE_WO_IKE'} == 1) {
		set_sa();
	}
	# end

	# Prepare the memory which stores the reception packet.
	vCapture($IF0);
	vClear($IF0);

	return;
}

#-----------------------------------------------------------------------------#
# Term_Test(@)
#-----------------------------------------------------------------------------#
sub Term_MN(@) {
	my ($if, $flag) = @_;
	my $unexpect, $rtn, $kind_name, $no;
	my %packet;

	# find strange packets
	if ( @UNEXPECT ) {
		vLogHTML("<TR><TD></TD><TD><B>Unexpect packet is examined.</B><BR>");

		set_frames();

		for $unexpect ( @UNEXPECT ) {
			($rtn, $kind_name) = get_strange_unexpect(0, \%$unexpect);
			$no = $$unexpect{vRecvPKT} - 1;
			if ($rtn == 1){
				vLogHTML("<A HREF=\"#vRecvPKT$no\">    packet is $kind_name</A>".
				         "<B><FONT COLOR=\"#FF8080\">:  WARN: This packet might be a failure that should not be sent.</FONT></B><BR>");
				$warncount ++;
			}
			else {
				vLogHTML("<A HREF=\"#vRecvPKT$no\">    packet is $kind_name</A><BR>");
			}
		}
		vLogHTML("</TD></TR>");
	}

	# Real Home Link
	if (($MN_CONF{TEST_FUNC_REAL_HOME_LINK} eq 'YES') && ($MN_CONF{ENV_INITIALIZE} eq 'RETURN')) {
		vLogHTML("<TR><TD></TD><TD>");
		vLogHTML("<B>*************************************************</B><BR>");
		vLogHTML("<B>End of TEST: NUT return Home Link.</B><BR>");
		vLogHTML("<B>It is unrelated to the judgment at the following.</B><BR>");
		vLogHTML("<B>*************************************************</B><BR>");
		vLogHTML("</TD></TR>");
		set_link_lifetime('Link0', $PREFIX_LIFETIME, $PREFIX_LIFETIME);
		@HA_BA_VALUE = ();
		$HA_BA_LIFETIME = 0;
		if ($NOW_Link eq 'LinkX') {
			vRecv_at_LinkX($if, $DAD_TIME);
		}
		elsif ($NOW_Link eq 'LinkY') {
			vRecv_at_LinkY($if, $DAD_TIME);
		}
		$ha_flg = 0;
		$cn_flg = 0;
		$now_time = time;
		$end_time = $now_time + $DAD_TIME;
		while ($now_time < $end_time) {
			$sec = $end_time - $now_time;
			%packet = vRecv_at_Link0_return($if, $sec,
				'bu_nuthga_ha0ga',
				'bu_nuthga_ha0ga_hoa_nuthga',
				'bu_nuthga_cn0ga',
				'bu_nuthga_cn0ga_hoa_nuthga');
			$now_time = time;
			if (($packet{recvFrame} eq 'bu_nuthga_ha0ga') ||
			    ($packet{recvFrame} eq 'bu_nuthga_ha0ga_hoa_nuthga')) {
				vSend_ba($if, 'ba_ha0ga_nuthga', \%packet);
				$ha_flg = 1;
			}
			elsif (($packet{recvFrame} eq 'bu_nuthga_cn0ga') ||
			       ($packet{recvFrame} eq 'bu_nuthga_cn0ga_hoa_nuthga')) {
				vSend_ba_cn($if, 'ba_cn0ga_nuthga', \%packet);
				$cn_flg = 1;
			}
			if (($ha_flg == 1) && ($cn_flg == 1)) {
				last;
			}
		}
	}

	# Terminate the state of TARGET.
	term_mn();

	return;
}

# End of File
1;
