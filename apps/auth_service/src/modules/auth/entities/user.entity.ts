import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

export enum UserRole {
  POSTER = 'POSTER',
  SEEKER = 'SEEKER',
}

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  email: string;

  @Column({ select: false }) // Security: Password won't be returned in JSON by default
  password: string;

  @Column()
  fullName: string;

  @Column()
  city: string;

  @Column()
  area: string;

  @Column({
    type: 'enum',
    enum: UserRole,
    default: UserRole.POSTER,
  })
  currentRole: UserRole;

  // Seeker specific: List of skills (empty for posters)
  @Column('text', { array: true, nullable: true })
  skills: string[];

  // JSON storage for reviews to keep them separate
  @Column('jsonb', { default: [] })
  seekerReviews: any[];

  @Column('jsonb', { default: [] })
  posterReviews: any[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}