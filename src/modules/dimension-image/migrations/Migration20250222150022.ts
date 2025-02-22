import { Migration } from '@mikro-orm/migrations';

export class Migration20250222150022 extends Migration {

  override async up(): Promise<void> {
    this.addSql(`alter table if exists "dimension_image" add column if not exists "ref" text not null;`);
  }

  override async down(): Promise<void> {
    this.addSql(`alter table if exists "dimension_image" drop column if exists "ref";`);
  }

}
