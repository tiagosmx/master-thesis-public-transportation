/**
 * Interface used for defining a column name and its type and property mapping
 */
export default interface ColumnDefinition {
  readonly cName: string;
  readonly cType: string;
  readonly pName: string;
}
