import { Migration } from '@mikro-orm/migrations';

export class Migration20250222142453 extends Migration {

  override async up(): Promise<void> {
    this.addSql(`create table if not exists "dimension_image" ("id" text not null, "url" text not null, "created_at" timestamptz not null default now(), "updated_at" timestamptz not null default now(), "deleted_at" timestamptz null, constraint "dimension_image_pkey" primary key ("id"));`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_dimension_image_deleted_at" ON "dimension_image" (deleted_at) WHERE deleted_at IS NULL;`);
  }

  override async down(): Promise<void> {
    this.addSql(`drop table if exists "dimension_image" cascade;`);
  }

}
