//
//  NoteDefs.h
//  Cellular-Sounds
//
//  Created by Vasco Orey on 4/29/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#ifndef Cellular_Sounds_NoteDefs_h
#define Cellular_Sounds_NoteDefs_h

//C3 = 36, D = 38, E = 40, F = 41, G = 43, A = 45, B = 47

#define kMAJ_NOTES @[@(0), @(2), @(4), @(5), @(7), @(9), @(11)]
#define kMIN_NOTES @[@(0), @(2), @(3), @(5), @(7), @(8), @(10)]
#define kMAJ_PENT_NOTES @[@(0), @(2), @(4), @(7), @(9), @(12)]
#define kMIN_PENT_NOTES @[@(0), @(3), @(5), @(7), @(10), @(12)]
#define kMAJ_ARPEGGIOS @[@(0), @(4), @(7), @(2), @(5), @(9), @(4), @(7), @(10), @(5), @(9), @(12), @(7), @(11), @(14), @(9), @(12), @(16), @(11), @(14), @(17)]
#define kSCALES @{@"Major" : kMAJ_NOTES, @"Minor" : kMIN_NOTES, @"Major Pentatonic" : kMAJ_PENT_NOTES, @"Minor Pentatonic" : kMIN_PENT_NOTES, @"Major Arpeggios" : kMAJ_ARPEGGIOS}
#define kNUM_NOTES 120
#define kNOTE_NAMES @[@"C", @"C#", @"D", @"D#", @"E", @"F", @"F#", @"G", @"G#", @"A", @"A#", @"B"]
//C D E G A C
//#define C_PENT_MAJ_NOTES @[@(36), @(38), @(40), @(43), @(45), @(48)]
//A C D E G A
//#define A_PENT_MIN_NOTES @[@(21), @(24), @(26), @(28), @(31), @(33)]
//Arpeggios
//C - E - G, D - F - A, E - G - B
//#define C_MAJ_ARPEGGIOS @[@(24), @(28), @(31), /**/ @(26), @(29), @(33), /**/ @(28), @(31), @(35)]

#endif
