# Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
# All rights reserved.
# SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
# Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.

import pytest
from app.services.crdt_resolver import CRDTHybridClock

def test_hlc_clock_generation_and_ordering():
    clock = CRDTHybridClock("test_node_01")
    hlc1 = clock.generate()
    hlc2 = clock.generate()

    assert hlc1 != hlc2
    assert CRDTHybridClock.compare(hlc2, hlc1) == 1
    assert CRDTHybridClock.compare(hlc1, hlc2) == -1
    assert CRDTHybridClock.compare(hlc1, hlc1) == 0

def test_hlc_comparison_with_different_timestamps():
    earlier_hlc = "1710000000000:0001:node_a"
    later_hlc = "1710000005000:0000:node_b"

    assert CRDTHybridClock.compare(later_hlc, earlier_hlc) == 1
    assert CRDTHybridClock.compare(earlier_hlc, later_hlc) == -1
