// src/modules/auth/entities/job.entity.ts
import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from './user.entity';

export enum JobStatus {
  OPEN = 'OPEN',           // Abhi post hui hai
  BIDDING = 'BIDDING',     // Seeker ne offer bheji hai
  IN_PROGRESS = 'IN_PROGRESS', // Poster ne accept karli, kaam chal raha hai
  COMPLETED = 'COMPLETED', // Kaam khatam
  CANCELED = 'CANCELED',   // Job cancel ho gayi
}

export enum GenderPreference {
  MALE = 'MALE',
  FEMALE = 'FEMALE',
  ANY = 'ANY',
}

@Entity('jobs')
export class Job {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column('text')
  description: string;

  @Column({ nullable: true })
  attachments: string; // Filhal string rakhte hain (URL ke liye)

  // Location logic
  @Column({ default: false })
  isRemote: boolean; // Agar online kaam hai to true

  @Column({ type: 'decimal', precision: 10, scale: 8, nullable: true })
  latitude: number;

  @Column({ type: 'decimal', precision: 11, scale: 8, nullable: true })
  longitude: number;

  @Column()
  address: string; // Precise location name or area

  // Timing
  @Column()
  expectedDuration: string; // e.g., "2 hours"

  @Column({ type: 'timestamp' })
  startTime: Date; // Kab kaam shuru karna hai

  // Preferences & Pricing
  @Column({
    type: 'enum',
    enum: GenderPreference,
    default: GenderPreference.ANY,
  })
  genderPreference: GenderPreference;

  @Column()
  priceType: 'FIXED' | 'HOURLY';

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  priceValue: number;

  @Column({
    type: 'enum',
    enum: JobStatus,
    default: JobStatus.OPEN,
  })
  status: JobStatus;

  // Relationships
  @ManyToOne(() => User)
  @JoinColumn({ name: 'posterId' })
  poster: User;

  @Column()
  posterId: string;

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'selectedSeekerId' })
  selectedSeeker: User;

  @Column({ nullable: true })
  selectedSeekerId: string;

  @CreateDateColumn()
  createdAt: Date;
}